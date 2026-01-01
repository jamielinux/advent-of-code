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

_Q: Keep connecting together pairs of junction boxes until they're all in the
same circuit. Take the X coordinates of the last two junction boxes that were
connected and multiply them together. What is the result?_

## Notes

My approach is mostly the same as Part 1, but we keep connecting until all
boxes are in a single circuit, then return the last two boxes that were
connected.

Each connection we make does one of the following:

- creates a new 2-box circuit from two unconnected boxes
- adds an unconnected box to an existing circuit
- merges two separate circuits into one

So to connect `N` boxes into a single circuit, we need exactly `N-1`
connections.

> [!NOTE]
> I had to break the `No Jinja blocks` rule here. I wasn't able to think of
> a way to reduce the number of iterations needed.

## Playbook runtime

2 minutes 45 seconds.
