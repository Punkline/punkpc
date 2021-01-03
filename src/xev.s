/*## Header:
# --- xev
# eXtract EValuation
# Extract an expression from part of a given string, and attempt to evaluate it as an integer

##*/
##/* Updates:
# version 0.0.1
# - added to punkpc module library



##*/
/*## Attributes:
# --- Class Properties

# --- xev     - returned integer property, from xev operation
# --- xev.beg - beginning index from previous xev operation
# --- xev.end - ending index from previous xev operation
# --- xev.len - total length of range from previous xev operation



# --- Class Methods

# --- xev  beg, end, string
# Extract a substring from target range
#   beg    : beginning index of range (inclusive)
#   end    : ending index of range (inclusive)
#   string : a string to extract a range of characters from



## Binary from examples:

## 00000010 00000011
## 00000012 00000013

##*/
/*## Examples:
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

##*/

.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module xev, 1
.if module.included == 0

  .macro xev,b=xe.beg,e=-1,va:vararg
    xe.beg=\b; xe.end=\e&(-1>>1); xe.len=xe.beg-1; xev=-1; xe.ch,\va
  .endm; .macro xe.ch,e,va:vararg;
    xe.i=-1; xe.len=xe.len+1;
    .irpc c,\va; xe.i=xe.i+1;
      .if xe.i>xe.end; .exitm; .elseif xe.i>=xe.len; xe.ch "\e\c",\va; .endif
    .endr; .if xev==-1;xev=\e; .endif
  .endm;
  .irp x,beg,end,len;xe.\x=0;.endr;xev=-1
.endif

/**/
