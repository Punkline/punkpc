# --- Check if Input Starts with a Numerical Expression
#>toc if
# - an if tool that checks the first char of input literals for a numerical expression
# - useful for catching arguments that can't be treated like symbols before creating any errors



# --- Class Properties

# --- num  - bool is True if a number is detected in first character of arg, else False
# --- nnum - not num -- inverse of num
# these globals can be used as evaluable properties in .if statements



# --- Class Methods

# --- ifnum arg
# checks if given arg is a literal number, or an arg that starts with a non-number

# --- ifnum_ascii arg
#.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module ifnum, 4
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
  .endm; .macro ifnum_ascii, n
    num=0; .irpc c,\n; ifnum.__get_ascii "'\c"; .exitm; .endr; ifnum.check_ascii
  .endm; .macro ifnum.check_ascii; nnum = 1
    .if num >= 0x28; .if num <= 0x2D; nnum=0; .exitm ;.endif; .endif
    .if num >= 0x2F; .if num <= 0x39; nnum=0; .exitm ;.endif; .endif
    .irp x, 0x21, 0x25, 0x26, 0x5B, 0x5D, 0x7C, 0x7E
      .if num == \x; nnum = 0; .exitm; .endif
    .endr; .if nnum; num = 0; .endif
  .endm; .macro ifnum.__get_ascii, c; num = \c; .endm

.endif
