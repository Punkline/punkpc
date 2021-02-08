# --- Bit Counter Tools
#>toc library
# - fast checks for counting unused bits in an integer
# - useful for finding integer sizes when creating masks, for compression

# --- Updates:
# version 0.0.2
# - added optional return symbol arguments for each method
# version 0.0.1
# - added to punkpc module library

# --- Class Properties

# --- bcount      - return value; to be copied to other symbols or used directly on macro return
# --- bcount.sign - returned sign of integer as 1 or 0, for signed methods




# --- Class Methods
# All methods return their value as 'bcount'
# - additionally, an optional return symbol may be given to copy 'bcount' to

# --- bcount      int, sym
# Count the number of bits used by an unsigned integer
# - looks for most significant true bit
# - this is an alias of "bcount.le" (little-endian bit count)
# --- bcount.signed   int, sym
# Count the number of bits used by a signed integer
# - always includes sign + up to 31 bits on Little End
# --- bcount.zsigned  int, sym
# Count the number of unused bits in a signed integer
# - does not include sign, but counts up to 31 sign-duplicate bits on Big End

# --- bcount.zbe  int, sym
# Count the number of Zeroed bits on the Big End (bigger digits, left side) of given integer
# --- bcount.zle  int, sym
# Count the number of Zeroed bits on the Little End (smaller digits, right side) of given integer
# --- bcount.be   int, sym
# Count the number of bits in use by a big-endian value (by inverting bcount.zbe)
# --- bcount.le   int, sym
# Count the number of bits in use by a little-endian value (by inverting bcound.zle)

.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module bcount, 2
.if module.included == 0

.macro bcount.zbe, i, rtrn=bcount;  bcount = 0; bcount.int = \i; bcount.len = 32;
  .if !bcount.int; bcount = 32; .else
    .rept 5; bcount.len = bcount.len >> 1  # 16, 8, 4, 2, 1  = 5 mask iterations
      .if !(bcount.int >> (32-bcount.len))
        bcount.int = bcount.int << bcount.len
        bcount = bcount + bcount.len
      .endif;
    .endr;
  .endif; \rtrn = bcount
.endm; .macro bcount.zle, i, rtrn=bcount;  bcount = 0; bcount.int = \i; bcount.len = 32;
  .if !bcount.int; bcount = 32; .else
    .rept 5; bcount.len = bcount.len >> 1
      .if !(bcount.int << (32-bcount.len))
        bcount.int = bcount.int >> bcount.len
        bcount = bcount + bcount.len
      .endif;
    .endr;
  .endif;  \rtrn = bcount
.endm; .macro bcount.be, i, rtrn=bcount; bcount.zle \i; bcount = 32-bcount; \rtrn = bcount
.endm; .macro bcount.le, i, rtrn=bcount; bcount.zbe \i; bcount = 32-bcount; \rtrn = bcount
.endm; .macro bcount, i, rtrn=bcount; bcount.zbe \i; bcount = 32-bcount; \rtrn = bcount
.endm; .macro bcount.signed,i, rtrn=bcount; bcount.sign = \i>>31; # sign bit is always used
  .if (\i==-1)||(\i==0); bcount = 2;
  .else; # assume at least 1 bit is used in signed integer field
    .if bcount.sign; bcount.le ~\i; .else; bcount.le \i; .endif; bcount=bcount+1; .endif
    \rtrn = bcount
.endm; .macro bcount.zsigned, i, rtrn=bcount; bcount.signed \i;
  bcount = 32 - bcount; \rtrn = bcount
.endm

.endif
/**/
