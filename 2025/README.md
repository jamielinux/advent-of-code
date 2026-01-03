<a id="readme"></a>

# Advent of Code, 2025 — Cursed Ansible Edition

My first ever [advent of code](https://adventofcode.com/2025/about)! 🎄

Also see
[Curious things I learned about Ansible in Advent of Code](./README.ansible.md).

## Self-imposed rules

Let's not make this too easy:

- No LLMs or search engines.
- No external commands (eg, `shell:`, `command:`, `lookup('pipe', ..)` etc).
- No custom plugins (eg, `my_filter.py`).
- No Jinja blocks (ie, `{% ... %}`).
- No extra dependencies (eg, `jmespath` for `json_query`)

## Why Ansible?

<details>

Ansible is quite unsuitable for advent of code:

- Only ~2 Ansible modules (out of 6000+) are useful for these puzzles
- No general-purpose functions (ie, global vars everywhere)
- Limited recursion
- No unbounded loops
- Limited loop flow control
- It's incredibly slow

But that's part of the fun!

</details>

## Solution notes

Here are links to my notes on each puzzle.

I'm certainly not an algorithm expert, but the goals were to have fun and see
how much I could stretch Ansible! 🤓

> [!NOTE]
> **The † means I had to use Jinja blocks.** Jinja loops are _much_ faster than
> Ansible loops, but feel like bypassing Ansible. So I stuck with Ansible loops
> unless the runtime would be days and if I was unable to think of a faster way.

| Day | Part 1                              | Part 2                              |
| --: | ----------------------------------: | ----------------------------------: |
|   1 |       [9s](./roles/d01p1/README.md) |      [12s](./roles/d01p2/README.md) |
|   2 |       [5s](./roles/d02p1/README.md) |      [12s](./roles/d02p2/README.md) |
|   3 |       [4s](./roles/d03p1/README.md) |      [37s](./roles/d03p2/README.md) |
|   4 |      [44s](./roles/d04p1/README.md) |   [32m51s](./roles/d04p2/README.md) |
|   5 |      [10s](./roles/d05p1/README.md) |       [5s](./roles/d05p2/README.md) |
|   6 |      [30s](./roles/d06p1/README.md) |    [2m19s](./roles/d06p2/README.md) |
|   7 |       [1s](./roles/d07p1/README.md) |      [13s](./roles/d07p2/README.md) |
|   8 |  † [2m25s](./roles/d08p1/README.md) |  † [2m45s](./roles/d08p2/README.md) |
|   9 |      [13s](./roles/d09p1/README.md) |    [7m08s](./roles/d09p2/README.md) |

## Running the playbooks

<details>

### Install software

Install [`just`][install-just] and [`uv`][install-uv].

[install-just]: https://github.com/casey/just?tab=readme-ov-file#installation
[install-uv]: https://docs.astral.sh/uv/getting-started/installation/

### Prepare inputs

Each role needs inputs from [Advent of Code, 2025][aoc-2025].

For example, for **Day 1 Part 1**, create the file
`roles/d01p1/files/input.txt` with your inputs.

[aoc-2025]: https://adventofcode.com/2025

### Run

See available playbooks:

```console
$ just
```

Run a playbook:

```console
$ just d01p1
```

</details>
