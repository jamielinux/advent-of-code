# Day 5: Part 1

## Instructions

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

_Q: How many of the available ingredient IDs are fresh?_

## Notes

Looping through the available IDs and checking them against each range is
pretty slow, so my approach was to:

- do a version sort of the ranges as strings (ie, they'll be sorted by start
  ID, and then end ID is the tie-breaker)
- parse the ranges into a dict of start ints and end ints
- merge overlapping ranges to reduce the number of iterations:
    - for each range, lookahead to see if the end of the current range is
      greater than or equal to the beginning of the next range
- loop through available IDs and check them against the merged ranges
    - additionally, we can avoid iterating when the available IDs are lower
      than the lowest fresh ID or higher than the highest

## Playbook runtime

10 seconds.
