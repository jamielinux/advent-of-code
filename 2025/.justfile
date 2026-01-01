set shell := ["bash", "-c"]

[private]
default: help

[private]
@help:
  just --list

# Lint
lint:
  uv run ansible-lint *.yml

[private]
_run day part *args:
  ANSIBLE_STDOUT_CALLBACK="ansible.builtin.selective" uv run \
    ansible-playbook d{{day}}.yml -i inventory/hosts --tags p{{part}} {{args}}

[private]
_run_debug day part *args:
  uv run ansible-playbook d{{day}}.yml -i inventory/hosts --tags p{{part}} {{args}}

# Day 1 Part 1
d01p1 *args: (_run "01" "1" args)

# Day 1 Part 1 (with full ansible output)
d01p1-debug *args: (_run_debug "01" "1" args)

# Day 1 Part 2
d01p2 *args: (_run "01" "2" args)

# Day 1 Part 2 (with full ansible output)
d01p2-debug *args: (_run_debug "01" "2" args)

# Day 2 Part 1
d02p1 *args: (_run "02" "1" args)

# Day 2 Part 1 (with full ansible output)
d02p1-debug *args: (_run_debug "02" "1" args)

# Day 2 Part 2
d02p2 *args: (_run "02" "2" args)

# Day 2 Part 2 (with full ansible output)
d02p2-debug *args: (_run_debug "02" "2" args)

# Day 3 Part 1
d03p1 *args: (_run "03" "1" args)

# Day 3 Part 1 (with full ansible output)
d03p1-debug *args: (_run_debug "03" "1" args)

# Day 3 Part 2
d03p2 *args: (_run "03" "2" args)

# Day 3 Part 2 (with full ansible output)
d03p2-debug *args: (_run_debug "03" "2" args)

# Day 4 Part 1
d04p1 *args: (_run "04" "1" args)

# Day 4 Part 1 (with full ansible output)
d04p1-debug *args: (_run_debug "04" "1" args)

# Day 4 Part 2
d04p2 *args: (_run "04" "2" args)

# Day 4 Part 2 (with full ansible output)
d04p2-debug *args: (_run_debug "04" "2" args)

# Day 5 Part 1
d05p1 *args: (_run "05" "1" args)

# Day 5 Part 1 (with full ansible output)
d05p1-debug *args: (_run_debug "05" "1" args)

# Day 5 Part 2
d05p2 *args: (_run "05" "2" args)

# Day 5 Part 2 (with full ansible output)
d05p2-debug *args: (_run_debug "05" "2" args)

# Day 6 Part 1
d06p1 *args: (_run "06" "1" args)

# Day 6 Part 1 (with full ansible output)
d06p1-debug *args: (_run_debug "06" "1" args)

# Day 6 Part 2
d06p2 *args: (_run "06" "2" args)

# Day 6 Part 2 (with full ansible output)
d06p2-debug *args: (_run_debug "06" "2" args)

# Day 7 Part 1
d07p1 *args: (_run "07" "1" args)

# Day 7 Part 1 (with full ansible output)
d07p1-debug *args: (_run_debug "07" "1" args)

# Day 7 Part 2
d07p2 *args: (_run "07" "2" args)

# Day 7 Part 2 (with full ansible output)
d07p2-debug *args: (_run_debug "07" "2" args)

# Day 8 Part 1
d08p1 *args: (_run "08" "1" args)

# Day 8 Part 1 (with full ansible output)
d08p1-debug *args: (_run_debug "08" "1" args)

# Day 8 Part 2
d08p2 *args: (_run "08" "2" args)

# Day 8 Part 2 (with full ansible output)
d08p2-debug *args: (_run_debug "08" "2" args)

# Day 9 Part 1
d09p1 *args: (_run "09" "1" args)

# Day 9 Part 1 (with full ansible output)
d09p1-debug *args: (_run_debug "09" "1" args)
