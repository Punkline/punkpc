# --- Check if Input Starts with a Numerical Expression
#>toc if
# - an if tool that checks the first char of input literals for a numerical expression
# - useful for catching arguments that can't be treated like symbols before creating any errors

# --- Example use of the ifnum module:

.include "punkpc.s"
punkpc ifnum
# Use the 'punkpc' statement to load this module, or include the module file directly

myNumber = 100
# example of a symbol that is not a literal number

ifnum myNumber
.long num, nnum
# >>> 0, 1
# num is False, and nnum is True
# - this is because myNumber starts literally with 'm' instead of a decimal number

ifnum 100
.long num, nnum
# >>> 1, 0
# num is True, and nnum is False
# - this is because 100 starts with a '1'

ifnum +100
.long num, nnum
# >>> 2, 0
# num is True, and nnum is False
# - the value '2' is returned if an expression symbol was found in place of a number, like '+'
# - this evaluates to True just like in the previous example, but in a distinguishable way


# These symbols, 'num' and 'nnum' can be evaluated by a regular .if statement:

.if num;  .long myNumber
.else;    .long 0;  .endif
# >>> 100
# - this emits 'myNumer' because 'num' is True
# - if it were false, then 0 would be emitted

ifnum myNumber
.if num;  .long myNumber
.else;    .long 0;  .endif
# >>> 0

# This logic may be useful for checking if arguments are safe to use with 'ifdef'

punkpc ifdef
# - load ifdef module

ifnum_ascii 100
# This is a variation of ifnum that uses an ascii value for 'TRUE' instead of just '1'
# - it requires noaltmacro mode, and may be sensitive to certain types of inputs

.if num;  .long num; .endif
.if nnum; .long 0; .endif
# >>> 0x31
# the literals '100' starts with a valid non-alphabetical numerical expressions character
# - 'num' is returned as a bool -- 0 for FALSE;  1 for TRUE
# - 'nnum' is 'not num', and can be used for inverted logic
# - 'num_ascii' is the ascii encoding for the captured character, if 'num' is TRUE
#   - if 'num' if FALSE, num_ascii will be set == num

.macro checker, arg
  # this macro will return a 'check' value to determine what type of argument it was given
  check = 0
  .ifb \arg; .exitm; .endif
  check = 1
  ifnum \arg            # return '0' if arg is blank
  .if nnum; ifdef \arg  # return '1' if arg is a literal number
    .if def; check = 2  # return '2' if arg is a defined symbol number
    .else;   check = 3  # return '3' if arg is none of the above
  .endif; .endif
.endm

checker this_isnt_defined
.long check
# >>> 3 -- arg is not blank, not a number, and not a defined symbol

checker 100
.long check
# >>> 1 -- arg is a literal number, because it starts with a decimal number character

checker myNumber
.long check
# >>> 2 -- arg is a defined symbol

checker
.long check
# >>> 0 -- blank argument

checker ""
.long check
# >>> 0 -- blank string argument

.altmacro
checker <>
.long check
# >>> 0 -- blank altstring argument


# --- using 'ifnum_ascii'

.noaltmacro
# exit altmacro mode, from previous test

.macro if_minus, arg
  ifnum_ascii \arg
  .if num == 0x2D;
    .long 1  # emit TRUE if arg starts with a minus char
  .else
    .long 0  # emit FALSE if not a minus char
  .endif
.endm
# this macro checks for ascii char '-' with 0x2D
# - since '-' is valid in numerical expressions, it is detected by ifnum

if_minus 100
# >>> 0
# 100 does not start with '-'

if_minus -100
# >>> 1
# -100 does start with '-'

test = -100
if_minus test
# >>> 0
# 'ifnum' only checks literal inputs, not evaluations


# --- using 'ifnum.check_ascii'

a = '1
b = 'l
# set 'a' and 'b' to the value of a decimal number, and a non-number

num = a
# manually assign 'num' the value you want to check

ifnum.check_ascii
# 'num' and 'nnum' are returned as though 'ifnum' were called

.if num; .long 1; .else; .long 0; .endif
# >>> 1
# 'a' evaluates to a number character

num = b
ifnum.check_ascii
.if num; .long 1; .else; .long 0; .endif
# >>> 0
# 'b' evaluates to a letter character, not a number

# --- Example Results:

## 00000000 00000001
## 00000001 00000000
## 00000002 00000000
## 00000064 00000000
## 00000031 00000003
## 00000001 00000002
## 00000000 00000000
## 00000000 00000000
## 00000001 00000000
## 00000001 00000000
