# Day 1: Part 1

## Instructions

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

_Q: How many times is the dial left pointing at `0` after making each rotation?_

## Notes

The first problem was how to read the file into something Ansible can iterate
through. You can use `lookup` to read a file, but you just get one big string.

My approach was to use `regex_replace` to manipulate the list of instructions
into a yaml list of positive and negative integers:

```yaml
- name: 'set_fact: input'
  ansible.builtin.set_fact:
    input: >
      {{
        lookup('ansible.builtin.file', 'input.txt')
        | regex_replace('R', '- ')
        | regex_replace('L', '- -')
      }}
```

So if the original input file is:

```
R42
L17
L73
```

We get:

```yaml
- 42
- -17
- -73
```

And we can use `from_yaml` to parse this into a list object that Ansible can
iterate through.

Then it's just a matter of using modulo 100 and keeping track of the dial
position after every rotation.

## Playbook runtime

9 seconds.
