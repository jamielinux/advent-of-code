# Day 6: Part 2

## Instructions

You have input like this:

```
 87 412 293  56
 32 17   41 458
194 63   18 102
*   +   *   +
```

- This is math homework.
- Each **problem** is written right-to-left in columns:
    - The 1st problem is `682 + 550 + 41`.
    - The 2nd problem is `318 * 941 * 2`.
- Assumptions that aren't in the original instructions:
    - All columns have contiguous digits (ie, there's never an empty space
      between two digits in the same column).
    - The symbol is always after the last vertical number in a problem.

_Q: Calculate the results of each problem. What is the sum of all the results?_

## Notes

A nested loop over rows and columns is rather expensive, but fortunately we can
use regex instead:

- loop through each column of characters, starting from the last column
- for each column, extract the vertical digit string using regex:
    - `map('regex_replace', '^.{N}(.).*$', '\1')` extracts char at position `N`
       from each row
    - `select('match', '^[0-9]$')` matches digits (discarding empty spaces)
    - `join` concatenates them into a number

I guess there's still a more efficient method than regex... but I'm _so_ done
with math homework so on to the next one! 🙅‍♂️

## Playbook runtime

2 minutes 19 seconds.
