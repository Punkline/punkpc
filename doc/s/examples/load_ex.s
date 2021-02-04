# --- Load Immediate(s)
#>toc ppc
# - a tool for creating multi-immediate loads
# - immediates larger than 16-bits will require multiple instructions
#   - you can use this macroinstruction to string together as many as you need for a given input

# --- Example use of the load module:

.include "punkpc.s"
punkpc load
# Use the 'punkpc' statement to load this module, or include the module file directly

li r0, 1
load r0, 1
# 'load' works like 'li'.

load r4, 0x804019F4, ">Hello World!"
stswi r5, r4, load.len-4
# 'load' can handle 32-bit values, multiple arguments, and even strings that start with '>'
#  the 'load.len' property saves the byte size taken up in the registers



# --- a note about load evaluations:
# load.opt=1 by default
# if load.opt==0, 'load' will not optimize the number of instructions used
#  - when not optimized, non-constant expressions can still be used if they evaluate later on
#  - otherwise, default requires that all given expressions are evaluable



# This scenario is most commonly an issue with label math:

load.opt=0;  load r0, distance
# 'load' can handle expressing '_forward' before it is defined, but uses 2 instructions to do so


_back=.
nop
nop
_forward=.
distance = _forward-_back
# this evaluates to '8' midway through the assembly
# - the load.opt=0 load (above) will resolve once this is evaluated
#   - setting load.opt=1 will cause an early evaluation to be attempted, throwing an error


# Now that 'distance' is evaluated, it is safe to use a load.opt=1 load:

load.opt=1;  load r0, distance
# optimized 'load' uses only 1 instruction, but needs to be used after '_forward' is evaluable

# --- Example Results:

## 38000001 38000001
## 3C808040 608419F4
## 3CA04865 60A56C6C
## 3CC06F20 60C6576F
## 3CE0726C 60E76421
## 7CA465AA 3C000000
## 60000008 60000000
## 60000000 38000008
