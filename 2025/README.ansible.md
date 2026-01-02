# Curious things I learned about Ansible in Advent of Code

Advent of code highlighted some interesting things about Ansible that are less
noticeable in normal infrastructure code 🕵️

> [!NOTE]
> Jinja blocks (ie, `{% ... %}`) can bypass all of this, but I restricted myself
> from using them in advent of code. Happily, this meant I learnt a few curious
> things about Ansible!

## Loops

Ansible has a _ridiculous_ overhead when looping.

> [!NOTE]
> Ran with `ANSIBLE_STDOUT_CALLBACK=selective` to avoid testing how fast my
> terminal can print.

Looping a single task is already slow:

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

# Executed in 14m13s.
```

There's also a huge initialization overhead. In this case, Ansible spends
~1m45s just preparing to start the loop!

### Why?

I think every loop iteration copies and re-evaluates nearly everything (eg,
task config, vars, templates, other internal structures etc).

It's even worse when looping over an `include_tasks`. It seems every iteration
is treated as a separate include (ie, each with its own config and copies of
everything), and even just initializing is expensive.

The slow-down when looping `include_tasks` scales ~quadratically with the
number of iterations. It seems that:

- `include_tasks` gets deduped by searching a list for matches
    - this is useful when running the same tasks on `N` hosts
    - [permalink to `ansible/ansible` code][included_file_L213_217]
- Python list search is `O(n)`.
- When looping over an `include_tasks`, every iteration is unique (due to loop
  vars) so can't be deduped:
  - iteration `1`: search list (`0` items), no match so append
  - iteration `2`: search list (`1` item), no match so append
  - iteration `N`: search list (`N-1` items), no match so append
  - total comparisons: `1 + 2 ... + N = N(N-1)/2 = O(n^2)`
  - `N=50k` iterations means 1.25B failed comparisons

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

## Appending to lists/dicts

Let's say we want to append the results of a loop into a list:

```yaml
- name: 'list of 100k ints (fake computation results)'
  set_fact:
    my_list: '{{ range(100000) | list }}'
    result: []

- name: 'append 10x in a loop (1M ints at the end)'
  set_fact:
    result: '{{ result + [my_list] }}'
  loop: '{{ range(10) | list }}'

# Executes in 8 seconds.
```

If we increase the iterations 5x (from 10 to 50), it doesn't take 40 seconds
(ie, `8x5`) but 244 seconds (30x slower)!

```yaml
- name: 'append 50x in a loop (5M ints at the end)'
  set_fact:
    result: '{{ result + [my_list] }}'
  loop: '{{ range(50) | list }}'

# Executes in 244 seconds.
```

The same thing applies when appending to a dict in a loop with `combine()`.

### Why?

The quadratic complexity(?) is probably because it needs to deserialize
`result` first, then append `[my_list]`, then serialize again.

```yaml
- name: 'list of 500k ints'
  set_fact:
    my_list: '{{ range(500000) | list }}'

# Task A takes 10.6 seconds. Peak mem 380 MB.
- set_fact:
    result: '{{ [my_list] }}'
  loop: '{{ range(10) | list }}'

# Task B takes 57.2 seconds. Peak mem 2.0 GB.
- set_fact:
    result: '{{ result + [my_list] }}'
  loop: '{{ range(10) | list }}'
```

My guess at what's happening:

- Ansible serializes modified variables after each loop iteration to persist
  them for the next iteration.
- Serialization cost is proportional to the size of the variable.
- Task A:
    - Each iteration serializes 500k items
    - 5M items (`10*500k`) worth of serialization
- Task B:
    - Iteration 1 serializes 500k items
    - Iteration 2 serializes 1M items
    - ...
    - Iteration 10 serializes 5M items
    - 27.5M items (`500k + 1M ... + 5M`) worth of serialization
- Task B took `5.4` times longer than Task A.
- This `5.4` be explained by serialization overhead: `27.5M / 5M = 5.5`

Memory usage also grows ~quadratically. One of my solution runs (before I knew
about this overhead) managed to hit out-of-memory on my 64GiB RAM desktop! 😅

I guess this is because *both* the old and new versions of `result` are in
memory, in *both* the serialized and deserialized forms.

### Mitigations

Append in batches to smaller intermediate lists and combine at the end:

- use [`batch()`][batch]
- use dynamic variable names (with [`vars` lookup][vars-lookup])
- combine in a single expression to avoid serialize/deserialize cycles

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

[inline-if]: https://jinja.palletsprojects.com/en/stable/templates/#if-expression
[product]: https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/product_filter.html
[combinations]: https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/combinations_filter.html
[vars-lookup]: https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/vars_lookup.html
[batch]: https://jinja.palletsprojects.com/en/stable/templates/#jinja-filters.batch
[included_file_L213_217]: https://github.com/ansible/ansible/blob/5e10a9160c96b238d788b1b196a4c3e80ba6a8bd/lib/ansible/playbook/included_file.py#L213-L217
[gh-issue]: https://github.com/ansible/ansible/issues/86371
