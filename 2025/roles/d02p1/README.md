# Day 2: Part 1

## Instructions

You have input like this (excluding the newlines):

```
17-43,4529173-4529841,92847-156203,1847283746-1847291054,
7283-9156,33847291-33902847,829-1547,62917384-62984721
```

Invalid IDs are any sequence of digits repeated twice. For example:

- `22` (ie, `2` repeated twice)
- `1212` (ie, `12` repeated twice)

_Q: What is the sum of all the invalid IDs?_

## Notes

With a normal programming language, you can get away with this naive approach:

- loop through each range of IDs
- skip if the ID has an odd number of digits
- check if the first half of the digits matches the second half

To loop through each range in Ansible:

```yaml
loop: >-
  {{
    range(id_range.start, id_range.end + 1) | list
  }}
```

But some of the input ranges are 200,000+ items and Ansible isn't designed for
this. It was hanging even just allocating the list 😅 Also, we can't make the
task file recursively call itself until the end of the range because we hit
`maximum recursion depth exceeded`.

So instead:

- given an example range `7-10000`
- split into subranges by orders of magnitude (`7-9,10-99,100-999...`)
- skip the subrange if the IDs have an odd number of digits
- take the first half of the start and end of each subrange
    - eg, `10` becomes `1`, `99` becomes `9`, and gives us the range `1-9`
- for each value in that range, concatenate the value with itself
    - eg, `1` becomes `11`, `2` becomes `22` ...
- see if that value is in the original range

This drastically reduces the items we have to iterate. For example, if
processing the range `3131219357-3131417388`:

| Start      | End        | Items   |
| ---------- | ---------- | ------- |
| 3131219357 | 3131417388 | 198,031 |
| 31312      | 31314      | 3       |

Instead of taking days to finish, it took seconds!

## Playbook runtime

5 seconds.
