# Day 2: Part 2

## Instructions

You have input like this (excluding the newlines):

```
17-43,4529173-4529841,92847-156203,1847283746-1847291054,
7283-9156,33847291-33902847,829-1547,62917384-62984721
```

Invalid IDs are any sequence of digits repeated _at least_ twice. For example:

- `22` (ie, `2` repeated twice)
- `1212` (ie, `12` repeated twice)
- `123123123` (ie, `123` repeated three times)
- `7777777` (ie, `7` repeated seven times)

_Q: What is the sum of all the invalid IDs?_

## Notes

In **Part 1**, we could ignore most of the IDs in the input ranges and even
ignore whole ranges when all IDs have an odd number of digits. In **Part 2**,
we don't have that luxury.

Again, this means ***we must find a way to avoid iterating through entire
ranges***.

So here is my overall approach:

- split each input range into subranges by orders of magnitude
- for each subrange, find truncation factors based on digit count
- iterate truncated subranges, repeating each value to reconstruct IDs
- check if candidates fall within the original range
- sum all unique invalid IDs

### Example

Let's say we have the input range `{ "start": 68, "end": 123456 }`.

#### Find factors for truncation

For even-length digit counts, the factor is always `length / 2`:

- `68-99` becomes `6-9`
- `1000-9999` becomes `10-99`
- `100000-123456` becomes `100-123`

For odd-length digit counts, factors are divisors excluding 1:

- 3 digits means factors `[3]`
- 9 digits means factors `[3, 9]`
- 15 digits means factors `[3, 5, 15]`

#### Resulting subranges

```json
[
  { "start": 68,     "end": 99,     "start_truncated": 6,   "end_truncated": 9   },
  { "start": 1000,   "end": 9999,   "start_truncated": 10,  "end_truncated": 99  },
  { "start": 100000, "end": 123456, "start_truncated": 100, "end_truncated": 123 }
]
```

#### Process each subrange

For `68-99`:

- iterate `6..9`
- concatenate (`66`, `77` ...)
- check if within non-truncated range (`68-99`)

Repeat for all subranges.

#### All-same-digit check

Each subrange only has integers of a certain number of digits, so for example
in a 5-digit subrange we check for `11111`, `22222` ... `99999`.

#### Pair-repeated check

For 6+ digit subranges with an even number of digits, also truncate to 2
digits so that we can check for N pairs of two digits.

For `10000-123456`:

- iterate `10..12`
- concatenate (`101010`, `111111`, `121212`)
- check if within non-truncated range

## Playbook runtime

12 seconds.
