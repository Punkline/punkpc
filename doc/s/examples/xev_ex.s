# --- Extract Evaluation Tool
#>toc library
# - for extracting evaluable literals from 2 known character indices in a given string argument
# - useful when parsing complex inputs for evaluable sub-expressions

# --- Example use of the xev module:

.include "punkpc.s"
punkpc xev
# Use the 'punkpc' statement to load this module, or include the module file directly

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

# --- Example Results:

## 00000010 00000011
## 00000012 00000013
