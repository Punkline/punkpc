/*## Header:
# --- ifnum - a method for quickly checking if an argument starts with a number or not

##*/
##/* Updates:
# version 0.0.3
# - ifnum will now return '1' if a decimal char was detected, and '2' if a math char was detected
# - added 'ifnum_ascii' variant for recording specific ascii encoding instead of just '1' or '2'
#   - in both cases, all non-0 values are 'TRUE', and should evaluate the same as in old versions
# version 0.0.2
# - added chars +-*%/&^!~()[] to number detection, for expressions
# version 0.0.1
# - added to punkpc module library



##*/
/*## Attributes:
# --- Class Properties

# --- num  - bool is True if a number is detected in first character of arg, else False
# --- nnum - not num -- inverse of num
# these globals can be used as evaluable properties in .if statements



# --- Class Methods

# --- ifnum arg
# checks if given arg is a literal number, or an arg that starts with a non-number



## Binary from examples:

## 00000000 00000001
## 00000001 00000000
## 00000002 00000000
## 00000064 00000000
## 00000031 00000003
## 00000001 00000002
## 00000000 00000000
## 00000000 00000000
## 00000001 00000000

##*/
/*## Examples:
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


##*/


.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module ifnum, 3
.if module.included == 0

  num=0; nnum=1;
  .macro ifnum, n
    num=0
    .irpc c,\n
      .irpc d,0123456789; .ifc \c,\d; num=1; .exitm; .endif; .endr;
      .if num == 0
        .irpc d,+-*%/&^!~()[]; .ifc \c,\d; num=2; .exitm; .endif; .endr;
      .endif; .exitm
    .endr
    nnum=!num
  .endm; .macro ifnum_ascii, n;
    num=0; nnum=1; .irpc c,\n; ifnum.get_ascii "'\c"; .exitm; .endr
    .if num >= 0x28; .if num <= 0x2D; nnum=0; .exitm ;.endif; .endif
    .if num >= 0x2F; .if num <= 0x39; nnum=0; .exitm ;.endif; .endif
    .irp x, 0x21, 0x25, 0x26, 0x5B, 0x5D, 0x7C, 0x7E
      .if num == \x; nnum = 0; .exitm; .endif
    .endr; .if nnum; num = 0; .endif
  .endm; .macro ifnum.get_ascii, c; num = \c; .endm

.endif