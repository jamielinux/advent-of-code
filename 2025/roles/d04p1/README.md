# Day 4: Part 1

## Instructions

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

_Q: How many rolls of paper can be accessed by the forklift?_

## Notes

My approach was to:

- create an expanded grid:
    - add an extra empty row (of `.` chars) at the start and end
    - add an extra empty column (of `.` chars) at the start and end
- store the whole grid as a list of lists so that we can use indexes as a
  coordinate system
- for each cell `X` containing `@`:
    - count `@` chars in the 3x3 cell block centered on `X`
    - subtract 1 and that's the number of adjacent rolls of paper

The expanded grid simplified adjacency calculations, as I didn't need any
special case handling for cells on the edge of the grid.

## Playbook runtime

44 seconds.
