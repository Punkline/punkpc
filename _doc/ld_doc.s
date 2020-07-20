# --- ld or load: LoaD immediate(s) - ld [reg], [value or string], [next value or string]...
#  can load multiple values or strings into a sequence of registers
#  strings should be quoted, and must begin with a '>' character for recognition
#  - number of instructions is minimized using optional evaluations (see extra note)
#  if [reg] is positive, that register will be the base of an incrementing register number
#  if [reg] starts with the literal char '-', the reg number is used with a decrementor instead
#  if [reg] is blank, a default of decrementing r31 is used to complement lmw/stmw syntax


# --- Example use of the ld module:

.include "./punkpc/ld.s"

li r0, 1
ld r0, 1; load r0, 1
# 'ld' works like 'li'. 'load' is an alias.
ld r4, 0x804019F4, ">Hello World!"
stswi r5, r4, ld.len-4
# 'ld' can handle 32-bit values, multiple arguments, and even strings that start with '>'
#  the 'ld.len' property saves the byte size taken up in the registers


# --- a note about ld evaluations:
# ld.opt=0 by default
# if ld.opt==0, 'ld' will not optimize the number of instructions used
#  - when not optimized, expressions with missing definitions can be used as values
#  - otherwise, default requires that all given expressions are evaluable
# this scenario is most commonly an issue with label math:

_back=.
ld.opt=0;  ld r0, _forward-_back
# 'ld' can handle expressing '_forward' before it is defined, but uses 2 instructions to do so
_forward=.
ld.opt=1;  ld r0, _forward-_back
# optimized 'ld' uses only 1 instruction, but needs to be used after '_forward' is evaluable
# if tried before '_forward' is defined, the value will stay 0 until the linker handles it
#   - when not using the linker, this may be useful for creating null terminators


# --- Module attributes:
# --- Class Properties ----------------------------------------------------------------------------

# --- ld.len  - returns length of last output (in bytes)
# --- ld.opt  - optimization flag
# - if True, (default) then fewer instructions are used to generate input, if possible
#   - this mode is not capable of handling undefined expressions (like forward label math)
# - if False, number of instructions used is not optimized
#   - this mode does not evaluate undefined expressions, and thus supports them


# --- Class Methods -------------------------------------------------------------------------------

# --- load reg, arg, ...
# - an alias for ld

