# --- xev
# eXtract EValuation
# Extract an expression from part of a given string, and attempt to evaluate it as an integer


# --- Example use of the xev module:

.include "./punkpc/xev.s"

xev 5,6,myVal16; .long xev
# >>> 00000010
# expression '16' is extracted from symbol name 'myVal16'
# the index range of 16 is 5 ... 6:  as stated in the first 2 arguments
# - 0123456
##  myVal16

xev 5,,myVal17; .long xev
# >>> 00000011
# a blank end range index selects end of string

xev,,myVal 18; .long xev
# >>> 00000012
# blank beginning index reselects last used beginning index; or 0 default

# Note: xev must be used on a range that includes a valid expression, or errors will be generated
# - this may include symbol names, math operators, and whitespace
# - the total captured string must be smaller in chars than the remaining callstack (~100 layers)

myvar = xev + 1
xev 3,,notmyvar; .long xev
# >>> 00000013
# the value of 'myvar' is evaluated in this case


# --- Module attributes:
# --- Class Properties ----------------------------------------------------------------------------

# --- xev     - returned integer property, from xev operation
# --- xev.beg - beginning index from previous xev operation
# --- xev.end - ending index from previous xev operation
# --- xev.len - total length of range from previous xev operation


# --- xev  beg, end, string
# Extract a substring from target range
#   beg    : beginning index of range (inclusive)
#   end    : ending index of range (inclusive)
#   string : a string to extract a range of characters from

