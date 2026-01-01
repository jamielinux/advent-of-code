# Things I learned about Ansible in Advent of Code (2025)

Advent of Code highlighted some interesting things about Ansible that are less
noticeable in normal infrastructure code 🕵️

> [!NOTE]
> Jinja blocks (ie, `{% ... %}`) maybe don't suffer from the same problems,
> but I restricted myself from using them in advent of code. Happily, this
> meant I learnt a few curious things about Ansible!

## Loops

Ansible has a _ridiculous_ overhead when looping.

> [!NOTE]
> Run these with `ANSIBLE_STDOUT_CALLBACK=selective` to avoid testing how fast
> your terminal can print.

Looping a single task is already slow:

```yaml
- hosts: localhost
  tasks:
    - set_fact:
        foo: true
      loop: '{{ range(10000) | list }}'

# Executed in 13 seconds.
```

If you want to loop over several tasks, you can use `include_tasks`:

```yaml
- hosts: localhost
  tasks:
    - include_tasks:
        file: include.yml
      loop: '{{ range(10000) | list }}'
```

If `include.yml` has the same single task as before, it runs 5x slower:

```yaml
# include.yml:
- set_fact:
    foo: true

# Executed in 74 seconds.
```

There's huge overhead even if it's a `noop` task:

```yaml
# include.yml:
- meta: noop

# Executed in 17 seconds.
```

### Why?

In general, Ansible has a lot of loop overhead.

It's even worse when looping `include_tasks`, as Ansible seems to initialize
all loop iterations before doing the tasks in the included file. In this case
it spent 17 seconds just initializing.

I tried the above with `range(100000)`:

- ~9 minutes initializing the loops
- ~20 seconds printing 100k lines about the loops before even looping
- ~20 seconds running `noop` tasks

### Mitigations

When you need to loop over many tasks, you can avoid `include_tasks` by using:

- [`product()`][product] or [`combinations()`][combinations]
- task-level `when:` and `vars:` (both are re-evaluated on each loop iteration)
- dynamic variable names (with [`vars` lookup][vars-lookup])
- [inline If Expressions][inline-if] (eg, `{{ 0 if true else 1 }}`)

You can avoid loops altogether in some cases by using filters in a chain:

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

- [Jinja's Builtin Filters][jinja-builtin-filters]
- [`ansible.builtin` filters][ansible-builtin-filters]
- [`community.general` filters][community-general-filters]

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

If we increase the loops 5x (from 10 to 50 iterations), it doesn't take
`8*5=40` seconds but 244 seconds (30x slower)!

```yaml
# same as before, but:
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
  them for the next iteration
- Serialization cost is proportional to the size of the variable
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

Memory usage also grows quadratically. One of my solution runs (before I knew
about this overhead) managed to hit out-of-memory on my 64GiB RAM desktop! 😅

I guess this is because *both* the old and new versions of `result` are in
memory, in *both* the serialized and deserialized forms.

### Mitigations

To mitigate the compounding overhead, append in batches to smaller intermediate
lists and combine them all at the end:

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
[ansible-builtin-filters]: https://docs.ansible.com/projects/ansible/latest/collections/index_filter.html#ansible-builtin
[community-general-filters]: https://docs.ansible.com/projects/ansible/latest/collections/community/general/index.html#filter-plugins
[jinja-builtin-filters]: https://jinja.palletsprojects.com/en/stable/templates/#list-of-builtin-filters
