# Day 1: Part 2

## Instructions

<details>

<summary>Same as Part 1</summary>

You have input like this:

```
R42
L17
L73
R89
L26
R3
L61
R55
L44
R78
...
```

- You have a dial with numbers `0-99`.
- The input is a series of rotations.
- The dial starts pointing at `50`.
- `R42` turns the dial clockwise `42` clicks.
- `L17` turns the dial anti-clockwise `17` clicks.

</details>

_Q: How many times does the dial either pass through `0` or end up pointing at
`0` after making each rotation?_

## Notes

My approach was:

- for each full rotation (eg, `L403` would have 4), increment the solution
- for the remaining partial rotation (eg, `L403` would have 3 clicks left):
    - increment solution if the dial passed through `0`, which we can tell by:
        - the dial position got lower after an `R` instruction
        - the dial position got higher after an `L` instruction
    - or increment solution if the dial ends on `0`

## Playbook runtime

12 seconds.
