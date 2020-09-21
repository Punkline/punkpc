/*## Header:
# --- ifnum - a method for quickly checking if an argument starts with a number or not

##*/
/*## Attributes:
# --- Class Properties ---

# --- num  - bool is True if a number is detected in first character of arg, else False
# --- nnum - not num -- inverse of num
# these globals can be used as evaluable properties in .if statements


# --- Class Methods ---

# --- ifnum arg
# checks if given arg is a literal number, or an arg that starts with a non-number

##*/
/*## Examples:
.include "./punkpc/ifnum.s"

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

.include "./punkpc/ifdef.s"
# - load ifdef module

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

##*/


.ifndef ifnum.included; ifnum.included = 0; .endif; .ifeq ifnum.included; ifnum.included = 1
  num=0;nnum=1;
  .macro ifnum, n;
    num=0;.irpc c,\n;.irpc d,0123456789;.ifc \c,\d;num=1;.exitm;.endif;.endr;.exitm;.endr;nnum=num^1
  .endm
.endif
