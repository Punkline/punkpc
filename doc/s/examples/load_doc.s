# --- load immediate(s) - load [reg], [value or string], [next value or string]...
#  can load multiple values or strings into a sequence of registers
#  strings shouload be quoted, and must begin with a '>' character for recognition
#  - number of instructions is minimized using optional evaluations (see extra note)
#  if [reg] is positive, that register will be the base of an incrementing register number
#  if [reg] starts with the literal char '-', the reg number is used with a decrementor instead
#  if [reg] is blank, a default of decrementing r31 is used to complement lmw/stmw syntax


# --- Updates:

# version 0.0.2
# - renamed module to 'load', because old name was not appropriate
#   - old name 'ld' is a powerpc instruction not used in mgekko, and is dissimilar to this macro
# - added 'load.purge'
# version 0.0.1
# - added to punkpc module library


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


# --- Module attributes:

# --- Class Properties

# --- load.len  - returns length of last output (in bytes)
# --- load.opt  - optimization flag
# - if True, (default) then fewer instructions are used to generate input, if possible
#   - this mode is not capable of handling undefined expressions (like forward label math)
# - if False, number of instructions used is not optimized
#   - this mode does not evaluate undefined expressions, and thus supports them


# --- Class Methods

# --- load  reg, arg, ...
# Loads (multiple, if needed) 32-bit immediates in 1 or 2 instructions
# reg : register value, but has 3 methods of interpretation:
#        if positive, register will be the base of an incrementing register number
#        -  ex: 3 =  r3, r4, r5, r6      for a 16-byte value
#        if reg literally starts with a '-' char, this becomes a decrementer instead
#        -  ex: 31 = r31, r30, r29, r28  for a 16-byte value
#        if blank, then a default of decrementing r31 is used to compliment lmw/stmw syntax
# arg : can be be either a value or a string that starts with '>'
# ... : multiple 32-bit args or variable-length strings can be loaded at once, in register sequence


## Binary from examples:

## 38000001 38000001
## 3C808040 608419F4
## 3CA04865 60A56C6C
## 3CC06F20 60C6576F
## 3CE0726C 60E76421
## 7CA465AA 3C000000
## 60000008 60000000
## 60000000 38000008




