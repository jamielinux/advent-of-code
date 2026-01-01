# Day 5: Part 2

## Instructions

<details>

<summary>Same as Part 1</summary>

You have input like this:

```
7-8
22-28
4-9
15-21

3
9
14
19
25
41
```

- Before the blank line are ranges of **fresh ingredient IDs**.
    - These are inclusive, so `7-8` means ingredients `7` and `8` are fresh.
    - The ranges can overlap.
    - An ingredient ID is fresh if it's in **any** range, else it's spoiled.
- After the blank line are the **available ingredient IDs**.

</details>

_Q: How many unique IDs are there in the fresh ingredient ID ranges?_

## Notes

In [Part 1](../d05p1/README.md) we already merged overlapping ranges, so this
part was basically already solved! I could just count the number of values in
each range and sum them 🥳

## Playbook runtime

5 seconds.
