# Day 3: Part 2

## Instructions

<details>

<summary>Same as Part 1</summary>

You have input like this:

```
429731856224817
163948572612384
785212369471526
394827152638294
```

- Each line is a ***bank***.
- Each bank has a series of ***batteries***, with a value from `1-9`.
- In each bank, _two_ batteries can be turned on and their values
  concatenated is the ***joltage***.
    - For example, turning on `4` and `9` in the first bank would give a joltage
      of `49`.
- You cannot rearrange the batteries.

</details>

This time, instead of turning on two batteries in each bank, you turn on twelve
batteries.

_Q: What is the sum of the largest joltage for each bank?_

## Notes

My approach was essentially to add a loop to [Part 1](../d03p1/README.md),
keeping a count `N` of the 12 digits we have left to find.

So (starting with `N=12`) for each bank:

- find the largest digit `X`, except for the last `N-1` digits in the bank
- get index of the first `X` (so we can ignore all the digits that came before)
- decrement `N`
- repeat until we have our 12 digits

## Playbook runtime

37 seconds.
