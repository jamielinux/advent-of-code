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

_Q: After connecting together 1000 pairs of junction boxes, multiply the sizes
of the three largest circuits. What is the result?_

## Notes

### Calculating the distance

At first I wasn't sure how to calculate the distance, but I realised we can get
there by calculating two hypotenuses in sequence.

To get the distance between `(0, 0)` and `(X, Y)`, we calculate the hypotenuse
(ie, Pythogoras):

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

Create a `boxes` dict, where the value represents circuit membership:

```yaml
"boxes": {
    "145,903,56": "",
    "175,842,730": "",
    "224,582,78": "",
    "284,531,647": "",
    "316,941,82": "",
    # ...
}
```

For every possible combination of box coordinates, add to `distances`:

```yaml
"distances": [
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

Take the shortest 1000 distances and follow these rules:

- skip if `box_a` and `box_b` are in the same circuit already
- if only `box_a` is in a circuit, add `box_b` to that circuit
- if only `box_b` is in a circuit, add `box_a` to that circuit
- if `box_a` is in `circuit_a` and `box_b` is in `circuit_b`, move all members
  of `circuit_b` to `circuit_a` (ie, merging two circuits together)

The `boxes` dictionary ends up looking like this:

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
    "493,287,851": "493,287,851",
    "503,761,445": "",
    "58,746,129": "145,903,56",
    "593,224,956": "493,287,851",
    "612,448,739": "493,287,851",
    # ...
}
```

In the example above, there are three boxes in the `493,287,851` circuit.

Finally, we can:

- count the number of members of each circuit
- take the longest three circuits
- multiply the lengths of those three circuits

> [!NOTE]
> I had to break the `No Jinja blocks` rule here. I wasn't able to think of
> a way to reduce the number of iterations needed.

## Playbook runtime

2 minutes 33 seconds.
