# --- Load Multiple Floats
#>toc ppc
# - can be used similarly to the `lmw` and `stmw` instructions, but for various float types
#   - `lmfs` and `stmfs` for single-precision
#   - `lmfd` and `stmfd` for double-precision
# - does not change the number of instructions required for multiple registers

# --- Example use of the lmf module:

.include "punkpc.s"
punkpc lmf
# Use the 'punkpc' statement to load this module, or include the module file directly


# --- BASIC USE ---
# can be used similar to stmw and lmw, but produces an instruction for each float stored/loaded

stmfd f29, 0x10(sp)
lmfd  f29, 0x10(sp)
# >> stfd f29,16(sp)
# >> stfd f30,24(sp)
# >> stfd f31,32(sp)
# - backup saved floats (as doubles)

# >> lfd f29,16(sp)
# >> lfd f30,24(sp)
# >> lfd f31,32(sp)
# - restore saved floats (as doubles)


# --- RANGES ---

lmfs  f3, 0x24(r31), f5
stmfs f3, 0x24(r31), f5
# - you can specify a range by adding an extra register argument, at the end
#>>> lfs f3,36(r31)
#>>> lfs f4,40(r31)
#>>> lfs f5,44(r31)
# - load float range f3...f5 (as singles)

#>>> stfs f3,36(r31)
#>>> stfs f4,40(r31)
#>>> stfs f5,44(r31)
# - store float range f3...f5 (as singles)

lmfs  f5, 0x24(r31), f3
stmfs f5, 0x24(r31), f3
# >>> lfs f5,36(r31)
# >>> lfs f4,40(r31)
# >>> lfs f3,44(r31)
# - reversed load order

# >>> stfs f5,36(r31)
# >>> stfs f4,40(r31)
# >>> stfs f3,44(r31)
# - reversed store order

# --- Example Results:

## DBA10010 DBC10018
## DBE10020 CBA10010
## CBC10018 CBE10020
## C07F0024 C09F0028
## C0BF002C D07F0024
## D09F0028 D0BF002C
## C0BF0024 C09F0028
## C07F002C D0BF0024
## D09F0028 D07F002C
