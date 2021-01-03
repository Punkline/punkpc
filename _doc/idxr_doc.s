# --- idxr: InDeX from Register (i/o syntax)
# Evaluates 'x' separately from 'r' from given input 'x(r)' by recording them as properties
# - outputs return properties 'idxr.x' and 'idxr.r'


# --- Updates:

# version 0.0.2:
# - refactored namespace to fit module name
# - refactored '.idx' and '.reg'  properties to 'x' and 'r' respectively
# - changed xr argument to a vararg, to allow for whitespace in input
# version 0.0.1
# - added to punkpc module library


# --- Example use of the idxr module:

.include "punkpc.s"
punkpc idxr
# Use the 'punkpc' statement to load this module, or include the module file directly

r31 = 31  # an alias for general purpose register 31
idxr 0x400(r31)
# this syntax  index(register)  is commonly used in load/store instructions
# being able to mimic it can be helpful for creating inputs that generate loading/storing routines

.long idxr.x, idxr.r
# >>> 00000400 0000001F
# 'idxr.x' copies the given index input
# 'idxr.r' separately copies the given register input


idxr (0x100<<2) ((2+29))
.long idxr.x, idxr.r
# >>> 00000400 0000001F
# only the right-most pair of parentheses are considered in capture


# --- Module attributes:

# --- Class Properties

# --- idxr.x  - extracted index value
# --- idxr.r  - extracted register value



# ---Class Methods

# --- idxr  x(r)
# extract an index value and a register value from an input argument
# x  : becomes idxr.x value
# r  : becomes idxr.r value
# - right-most parentheses '( )' captures 'r'





## Binary from examples:

## 00000400 0000001F
## 00000400 0000001F




