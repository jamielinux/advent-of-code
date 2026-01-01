# Day 6: Part 1

## Instructions

You have input like this:

```
 87 412 293  56
 32 17   41 458
194 63   18 102
*   +   *   +
```

- This is math homework.
- Each **problem** is arranged vertically.
    - The 1st problem is `87 * 32 * 194`.
    - The 2nd problem is `412 + 17 + 63`.

_Q: Calculate the results of each problem. What is the sum of all the results?_

## Notes

My approach was to:

- parse the input:
    - split the input into a list of rows, excluding the operation symbols
    - split each row into a list of ints
    - create a list of operations
    - we now have a list of lists, plus a list of operations we can match by index
- use `product` to flatten the nested loop (cols x rows) into a single loop
- for each cell, accumulate values into `col_X_values` and update a running
  product in `col_X_product` (using dynamic variable names)
- loop over those dynamic vars to compute the solution:
    - for `+` operations, sum the column values
    - for `*` operations, use the pre-computed product

Instead of a separate loop to multiply column values, we compute the running
product as we build each column. This avoids the overhead of additional Ansible
task iterations (which is usually more costly than simple arithmetic).

## Playbook runtime

30 seconds.
