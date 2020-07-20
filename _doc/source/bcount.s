/*## Header:
# --- Bit Counter module
# Provides macros for counting zero or most-significant big or little endian bits; for masking
# Bit counts can serve as an informative property for integer compression when packing/unpacking

##*/
/*## Attributes:
# --- Class Properties ---

# --- bcount      - return value; to be copied to other symbols or used directly on macro return
# --- bcount.sign - returned sign of integer as 1 or 0, for signed methods


# --- Class Methods ---

# --- bcount      int
# Count the number of bits used by an unsigned integer
# - looks for most significant true bit
# - this is an alias of "bcount.le" (little-endian bit count)
# --- bcount.signed   int
# Count the number of bits used by a signed integer
# - always includes sign + up to 31 bits on Little End
# --- bcount.zsigned  int
# Count the number of unused bits in a signed integer
# - does not include sign, but counts up to 31 sign-duplicate bits on Big End

# --- bcount.zbe  int
# Count the number of Zeroed bits on the Big End (bigger digits, left side) of given integer
# --- bcount.zle  int
# Count the number of Zeroed bits on the Little End (smaller digits, right side) of given integer
# --- bcount.be   int
# Count the number of bits in use by a big-endian value (by inverting bcount.zbe)
# --- bcount.le   int
# Count the number of bits in use by a little-endian value (by inverting bcound.zle)

##*/
/*## Examples:
.include "./punkpc/bcount.s"

bcount 0x1337
.byte bcount
# >>> 13 bits (13th bit from little end is most significant true bit)

bcount.signed -0x1337
.byte bcount
# >>> 14 bits (includes sign)

bcount.be 0xFFC00000
.byte bcount
# >>> 10 bits (from big end)

bcount.zbe 0x1337
.byte bcount
# >>> 19 unused zero bits (from big end)

bcount.zle 0x1337
.byte bcount
# >>> 0 unused zero bits (from little end)

bcount.zsigned -0x1337
.byte bcount
# >> 18 sign-duplicate bits (not in use by signed number, excludes sign)
##*/


.ifndef bcount.included; bcount.included=0; .endif; .ifeq bcount.included; bcount.included = 1

.macro bcount.zbe, i;  bcount = 0; bcount.int = \i; bcount.len = 32;
  .if !bcount.int; bcount = 32; .else
    .rept 5; bcount.len = bcount.len >> 1  # 16, 8, 4, 2, 1  = 5 mask iterations
      .if !(bcount.int >> (32-bcount.len))
        bcount.int = bcount.int << bcount.len
        bcount = bcount + bcount.len
      .endif;
    .endr;
  .endif
.endm; .macro bcount.zle, i;  bcount = 0; bcount.int = \i; bcount.len = 32;
  .if !bcount.int; bcount = 32; .else
    .rept 5; bcount.len = bcount.len >> 1
      .if !(bcount.int << (32-bcount.len))
        bcount.int = bcount.int >> bcount.len
        bcount = bcount + bcount.len
      .endif;
    .endr;
  .endif
.endm; .macro bcount.be, i; bcount.zle \i; bcount = 32-bcount;
.endm; .macro bcount.le, i; bcount.zbe \i; bcount = 32-bcount;
.endm; .macro bcount, i; bcount.zbe \i; bcount = 32-bcount;
.endm; .macro bcount.signed,i; bcount.sign = \i>>31; # sign bit is always used
  .if (\i==-1)||(\i==0); bcount = 2; .else; # assume at least 1 bit is used in signed integer field
    .if bcount.sign; bcount.le ~\i; .else; bcount.le \i; .endif; bcount=bcount+1; .endif
.endm; .macro bcount.zsigned, i; bcount.signed \i; bcount = 32 - bcount # count unused bits
.endm

.endif
/**/
