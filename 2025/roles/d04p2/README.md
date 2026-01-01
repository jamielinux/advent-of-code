# Day 4: Part 2

## Instructions

<details>

<summary>Same as Part 1</summary>

You have input like this:

```
@.@@.@@@.@
.@@@.@@.@@
@@.@@@.@.@
@@@..@@.@@
.@@@@.@@.@
@.@.@@@@@@
@@.@@@..@@
.@@@.@@@.@
@.@@@@.@@@
@@.@.@@.@.
```

- The `@` are ***rolls of paper***.
- The `.` are empty spaces.
- Each cell has up to 8 adjacent cells (including diagonals).
- The ***forklift*** can access rolls of paper that have less than 4 adjacent
  rolls of paper.

In the example input above, the `x` below indicate rolls of paper that can be
accessed:

```
x.@x.x@x.x
.@@@.@@.@x
@@.@@@.@.@
@@@..@@.@x
.@@@@.@@.@
x.@.@@@@@@
x@.@@@..@@
.@@@.@@@.@
x.@@@@.@@x
xx.x.xx.x.
```

</details>

This time, in each round of work, the ***forklift*** removes all of the
***rolls of paper*** that it can access. The forklift keeps doing additional
rounds of work until it can't remove any more rolls of paper.

_Q: How many rolls of paper in total can be removed by the forklift?_

## Notes

The puzzle involves what seems like an unbounded loop (which aren't possible in
Ansible), but thankfully we know the _upper bound_: if only one paper roll can
be removed in each pass, and no paper rolls remain at the end, this would take
`N` iterations where `N` is the starting number of paper rolls.

My approach was to:

- use a sparse dict (instead of a dense list of lists that I used in Part 1):
    - keys are coordinate strings like `"2,3"` (row,col)
    - values are `1` instead of `@` for easy summing
    - we only keep track of cells with a paper roll
    - this gives us smaller data structure and cheaper lookups
- for each paper roll in the sparse grid:
    - generate coordinates for a 3x3 square centered on the paper roll
    - sum the values that exist and subtract 1 (for the center cell) to get
      adjacent count
- loop until no more rolls can be removed

I think we'd struggle to get this faster without resorting to a Jinja block!
But I'm happy it finished in less than an hour 😎

## Playbook runtime

32 minutes 51 seconds.
