# Day 3: Part 1

## Instructions

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

_Q: What is the sum of the largest joltage for each bank?_

## Notes

My approach was to:

- loop through each bank
- find the largest digit `X`, except for the last digit in the bank
- get index of the first `X` (so we can ignore all digits that come before)
- find the largest digit `Y` out of the remaining digits in the bank
- concatenate `X` and `Y` together

## Playbook runtime

4 seconds.
