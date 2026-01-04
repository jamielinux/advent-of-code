# Day 8: Part 1

## Instructions

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

_Q: After connecting together the 1000 pairs of junction boxes that are closest
together, multiply the sizes of the three largest circuits. What is the result?_

## Notes

### Calculating the distance

At first I wasn't sure how to calculate the distance, but I realised we can get
there by calculating two hypotenuses in sequence.

To get the distance between `(0, 0)` and `(X, Y)`, we calculate the hypotenuse
(ie, Pythagoras):

```
distance_xy = sqrt(x² + y²)
```

To get the distance between `(0, 0, 0)` and `(X, Y, Z)`, we can use the
hypotenuse above to calculate the next hypotenuse (the one we care about):

```
distance_xyz = sqrt(distance_xy² + z²)
             = sqrt((sqrt(x² + y²))² + z²)
             = sqrt(x² + y² + z²)
```

When the starting co-ordinate isn't `(0, 0, 0)`, we can take the delta:

```
distance = sqrt((x₂ - x₁)² + (y₂ - y₁)² + (z₂ - z₁)²)
```

Since we only need to compare distances (not their actual values), we can skip
`sqrt()` entirely to save on computation. Squared distance preserves sort order:

```
distance_squared = (x₂ - x₁)² + (y₂ - y₁)² + (z₂ - z₁)²
```

### Approach

Split the 3D space into a grid of cells (eg, `12x12x12`) and only pair a
junction box with others in the same cell or the 26 adjacent cells.

Assuming `n` junction boxes that are uniformly distributed, the ideal grid has
`n^(1/3)` divisions per axis (ie, one box per cell). For example, `10x10x10`
grid for 1000 uniformly distributed junction boxes. To account for variance in
distribution, we use a multiplier: `1.2 * n^(1/3)`.

We try this guesstimated grid size first, then fallback to `2x2x2` if it's
possible we missed some pairs (ie, our grid was too granular). This guarantees
all pairs are considered because in `2x2x2` every cell is adjacent.

We track circuit membership with the `boxes` dict:

```yaml
"boxes": {
    "145,903,56": "145,903,56",   # in circuit "145,903,56"
    "175,842,730": "78,829,914",  # in circuit "78,829,914"
    "224,582,78": "",             # unconnected
    # ...
}
```

We store pairs in `sorted_pairs` (sorted by `distance_squared`):

```yaml
"sorted_pairs": [
    {
        "distance_squared": 23466,
        "point_a": "731,92,483",
        "point_b": "838,156,394"
    },
    {
        "distance_squared": 24994,
        "point_a": "493,287,851",
        "point_b": "593,224,956"
    },
    # ...
]
```

Take the N closest pairs and follow these rules:

- skip if both boxes are in the same circuit
- if neither are in a circuit, create a new circuit with both boxes
- if one box is in a circuit already, add the other box to that circuit
- if both boxes are in different circuits, merge the circuits

The `boxes` dict ends up looking like this:

```yaml
"boxes": {
    "145,903,56": "145,903,56",
    "175,842,730": "78,829,914",
    "224,582,78": "",
    "284,531,647": "",
    "316,941,82": "145,903,56",
    "369,175,602": "",
    "41,697,521": "",
    "429,68,187": "",
    "493,287,851": "493,287,851",  # in circuit "493,287,851"
    "503,761,445": "",
    "58,746,129": "145,903,56",
    "593,224,956": "493,287,851",  # in circuit "493,287,851"
    "612,448,739": "493,287,851",  # in circuit "493,287,851"
    # ...
}
```

Finally:

- count the members of each circuit
- take the longest three circuits
- multiply their sizes

## Playbook runtime

1 minute 34 seconds.
