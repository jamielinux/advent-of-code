# Day 8: Part 2

## Instructions

<details>

<summary>Same as Part 1</summary>

You have input like this:

```
284,531,647
731,92,483
58,746,129
493,287,851
827,614,372
145,903,56
612,448,739
369,175,602
78,829,914
956,33,267
503,761,445
224,582,78
687,319,863
41,697,521
838,156,394
175,842,730
429,68,187
764,503,619
316,941,82
593,224,956
```

- These are `X`, `Y`, `Z` coordinates for electrical **junction boxes**.
- Joining two junction boxes forms a circuit.
- The elves start connecting junction boxes by picking the two that are closest
  together (straight-line-distance).
- They continue to connect the next closest, and so on.
- They take no action if the junction boxes are already in the same circuit.

> [!NOTE]
> The original instructions say that all boxes start in a circuit of one
> (itself). But I think of them as being unconnected.

</details>

_Q: Keep connecting together pairs of junction boxes (in order of closeness)
until they're all in the same circuit. Take the X coordinates of the last two
junction boxes that were connected and multiply them together. What is the
result?_

## Notes

To connect `N` boxes into a single circuit, we need exactly `N-1` connections.

In Part 1 we knew we'd need the 1000 closest pairs, regardless of how many
connections are actually made. In Part 2 we need `N-1` connections but can't
predict how many candidate pairs that requires (as some pairs are noops when
both boxes are already in the same circuit).

Once again, we can't afford to iterate every possible pair. So I built on my
approach in Part 1: try progressively less granular grids until all boxes are
connected:

- start with a guesstimated optimal grid size (eg, `12x12x12`)
    - same formula I used in Part 1 (`1.2 * n^(1/3)`)
- if not fully connected yet, try the next grid size down (eg, `9x9x9`)
- if still not fully connected, try `6x6x6`, `3x3x3` and finally `2x2x2`
- `2x2x2` guarantees success as all cells are adjacent

(For both the example input and my real input, the guesstimated grid was
enough.)

## Playbook runtime

2 minutes 6 seconds.
