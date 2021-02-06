# --- Index (Register)
#>toc library
# - index (register) input extraction tool
# - useful for simulating load/store syntaxes like the `0x20(r30)` part of `lwz r3, 0x20(r30)`

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

# --- Example Results:

## 00000400 0000001F
## 00000400 0000001F
