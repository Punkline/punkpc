# --- Bit Counter module
# Provides macros for counting zero or most-significant big or little endian bits; for masking
# Bit counts can serve as an informative property for integer compression when packing/unpacking


# --- Example use of the bcount module:

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


# --- Module attributes:
# --- Class Properties ----------------------------------------------------------------------------

# --- bcount      - return value; to be copied to other symbols or used directly on macro return
# --- bcount.sign - returned sign of integer as 1 or 0, for signed methods


# --- Class Methods -------------------------------------------------------------------------------

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

# --- bcount.le   int
# Count the number of bits in use by a little-endian value (by inverting bcound.zle)

