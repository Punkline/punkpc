# --- Bit Counter Tools
#>toc library
# - useful for finding int sizes when creating masks, for compression

# --- Example use of the bcount module:

.include "punkpc.s"
punkpc bcount
# Use the 'punkpc' statement to load this module, or include the module file directly

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

# --- Example Results:

## 0D0E0A13 0012
