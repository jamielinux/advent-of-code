# Curious things I discovered about Ansible in Advent of Code

Advent of code highlighted some interesting things about Ansible that aren't
so noticeable in normal infrastructure code 🕵️

My two main findings:

1. The slow-down when looping `include_tasks` ***scales quadratically*** with
   the number of iterations.
2. Appending to lists/dicts in a loop has ***`O(N^2 × M)` complexity***
   (where `N=iterations`, `M=data_size`) for both time and memory. This easily
   causes out-of-memory problems.

<sub>Jinja blocks (ie, `{% ... %}`) can bypass this, but I chose not to use them
for advent of code.</sub>

## 1. Loops

> [!NOTE]
> Ran with `ANSIBLE_STDOUT_CALLBACK=selective` to avoid testing how fast my
> terminal can print.

Even looping just a single task is already slow:

```yaml
- hosts: localhost
  tasks:
    - name: 'set a variable to true 50,000 times'
      set_fact:
        foo: true
      loop: '{{ range(50000) | list }}'

# Executed in 57s.
```

To loop over several tasks, use `include_tasks` to include another file:

```yaml
- hosts: localhost
  tasks:
    - include_tasks:
        file: other_tasks.yml
      loop: '{{ range(50000) | list }}'
```

If `other_tasks.yml` has the same single task as before, it runs 14x slower:

```yaml
# other_tasks.yml:
- set_fact:
    foo: true

# Executed in 14m13s. 🚨
```

There's also a huge initialization overhead. In this case, Ansible spends
~1m45s just preparing to start the loop!

### Why?

Every loop iteration seems to copy and re-evaluate nearly everything (eg,
config, vars, templates etc).

It's even worse when looping over an `include_tasks`. Every iteration is
treated as a separate include (ie, each with its own config and copies of
everything), and even just starting the loop can take minutes.

**The slow-down when looping `include_tasks` scales <ins>_quadratically_</ins>
with the number of iterations:**

- `include_tasks` gets deduped by searching a list for matches
    - this is useful when running the same tasks on many hosts
    - [permalink to upstream ansible code][included_file_L213_L217]
- Python list search is `O(N)`.
- When looping over an `include_tasks`, every iteration is unique (due to loop
  vars) so can't be deduped:
  - iteration `1`: search list (`0` items), no match so append
  - iteration `2`: search list (`1` item), no match so append
  - iteration `N`: search list (`N-1` items), no match so append
  - total comparisons: `1 + 2 ... + N = N(N-1)/2 = O(N^2)`
  - `N=50k` iterations means ***1.25 billion*** failed comparisons 🚨

([I opened a GitHub Issue upstream][gh-issue].)

### Mitigations

You can avoid loops in some cases by chaining filters like `map()`:

```yaml
# Fast
- set_fact:
    result: "{{ items | map('int') | select('gt', 0) | sum }}"

# Slow
- set_fact:
    result: '{{ result + [item | int] }}'
  loop: '{{ items }}'
  when: item | int > 0
```

When you need to loop over many tasks, you can avoid `include_tasks` by using:

- [`product()`][product] or [`combinations()`][combinations]
- task-level `when:` and `vars:` (both are re-evaluated on each loop iteration)
- dynamic variable names (with [`vars` lookup][vars-lookup])
- [inline If Expressions][inline-if] (eg, `{{ 0 if true else 1 }}`)

## 2. Appending to lists/dicts

Let's say we want to append to a list in a loop:

```yaml
- name: 'list of 500k ints (fake computation results)'
  set_fact:
    my_list: '{{ range(500000) | list }}'
    result: []

# Task A takes 10.6 seconds. Peak mem 380 MB.
- set_fact:
    result: '{{ [my_list] }}'
  loop: '{{ range(10) | list }}'

# Task B takes 57.2 seconds. Peak mem 2.0 GB.
- set_fact:
    result: '{{ result + [my_list] }}'
  loop: '{{ range(10) | list }}'

# Task C crawls for hours(!), and gets killed by out-of-memory (64GiB RAM). 🚨
- set_fact:
    result: '{{ result + [my_list] }}'
  loop: '{{ range(100) | list }}'
```

The same thing applies when appending to a dict in a loop with `combine()`.

### Why?

Using `+` or `combine()` in a loop is `O(N^2)`.

> [!NOTE]
> In Python, you can use `.append()` or `.extend()` instead, but not in Ansible.

But it's actually even worse than `O(N^2)`! Two factors combine to cause `O(N²
× M)` (where `N=iterations`, `M=data_size`) for both time and memory:

1. **Ansible keeps <ins>_every_</ins> iteration's result in a list until the
   loop finishes.**
    - After `N` iterations, `1 + 2 + ... + N = N(N+1)/2` copies of `my_list` are
      stored.
2. **Ansible's finalization (ie, template result processing)
   <ins>_recursively recreates_</ins> nested container structures.**
    - Each inner `my_list` is recreated as a new list object.
    - This happens for *all* nested lists on *every* iteration, not just the
      new one!

<details>

<summary>Expand this to see upstream ansible code</summary>

Excerpt from [task_executor.py][task_executor_L228_L404]:

```python
def _run_loop(self, items):
    results = []
    for item_index, item in enumerate(items):
        # line 310, result includes ansible_facts:
        res = self._execute(templar=templar, variables=task_vars)

        # line 366: all results kept in memory:
        results.append(res)
    return results
```

Excerpt from [_jinja_bits.py][_jinja_bits_L1018_L1027]:

```python
# line 1018, recursively recreate nested dicts:
def _finalize_dict(o: t.Any, mode: FinalizeMode) -> t.Iterator[tuple[t.Any, t.Any]]:
    for k, v in o.items():
        if v is not Omit:
            yield _finalize_template_result(k, mode), _finalize_template_result(v, mode)


# line 1024, recursively recreate nested lists:
def _finalize_list(o: t.Any, mode: FinalizeMode) -> t.Iterator[t.Any]:
    for v in o:
        if v is not Omit:
            yield _finalize_template_result(v, mode)
```

</details>

The combined effect:

- Task A (ie, overwrite each iteration):
    - `10 iterations * 500k elements = 5M` element copies
- Task B (ie, append each iteration):
    - 1st iteration recreates 1 inner list = 500k element copies
    - ...
    - 10th iteration recreates 10 inner lists = 5M element copies
    - `500k + 1M ... + 5M = 27.5M` element copies
- Task B took `5.4x` longer than Task A, matching `27.5M / 5M = 5.5`

Memory use goes crazy because all those recreated lists are kept in memory:

- After iteration `N`, there are `N(N+1)/2` copies of `my_list` in memory.
- For even just `N=100`, that's already 5,050 copies!

### Mitigations

Append in batches to smaller lists and combine with a single expression:

- use [`batch()`][batch]
- use dynamic variable names (with [`vars` lookup][vars-lookup])
- combine in a single expression to avoid repeated list copying

```yaml
# Combine batch_1, batch_2 ... batch_N
- set_fact:
    result: >-
      {{
        range(num_batches)
        | map('string')
        | map('regex_replace', '^', 'batch_')
        | map('extract', vars)
        | sum(start=[])
      }}
```

[product]: https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/product_filter.html
[combinations]: https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/combinations_filter.html
[vars-lookup]: https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/vars_lookup.html
[inline-if]: https://jinja.palletsprojects.com/en/stable/templates/#if-expression
[batch]: https://jinja.palletsprojects.com/en/stable/templates/#jinja-filters.batch
[included_file_L213_L217]: https://github.com/ansible/ansible/blob/5e10a9160c96b238d788b1b196a4c3e80ba6a8bd/lib/ansible/playbook/included_file.py#L213-L217
[gh-issue]: https://github.com/ansible/ansible/issues/86371
[task_executor_L228_L404]: https://github.com/ansible/ansible/blob/5e10a9160c96b238d788b1b196a4c3e80ba6a8bd/lib/ansible/executor/task_executor.py#L228-L404
[_jinja_bits_L1018_L1027]: https://github.com/ansible/ansible/blob/5e10a9160c96b238d788b1b196a4c3e80ba6a8bd/lib/ansible/_internal/_templating/_jinja_bits.py#L1018-L1027
