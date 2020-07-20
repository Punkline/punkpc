/*## Header:
# --- idxr: InDeX from Register (i/o syntax)
# evaluates 'x' separately from 'r' from given input x(r) by recording them as properties
# - outputs return properties 'idxr.x' and 'idxr.r'

##*/
/*## Attributes:
# --- Class Properties ---

# --- idxr.x  - extracted index value
# --- idxr.r  - extracted register value


# ---Class Methods ---

# --- idxr  x(r)
# extract an index value and a register value from an input argument
# x  : becomes idxr.x value
# r  : becomes idxr.r value
# - right-most parentheses '( )' captures 'r'

##*/
/*## Examples:
.include "./punkpc/idxr.s"

r31 = 31  # an alias for general purpose register 31
idxr 0x400(r31)
# this syntax  index(register)  is commonly used in load/store instructions
# being able to mimic it can be helpful for creating inputs that generate loading/storing routines

.long idxr.x, idxr.r
# >>> 00000400 0000001F
# 'idxr.x' copies the given index input
# 'idxr.r' separately copies the given register input


idxr (0x100<<2) ((2+29))
.long idxr.x, idxr.r
# >>> 00000400 0000001F
# only the right-most pair of parentheses are considered in capture
##*/

.ifndef idxr.included; idxr.included=0; .endif; .ifeq idxr.included; idxr.included = 2; idxr.r=0
# version 0.0.2:
# - refactored namespace to fit module name
# - refactored '.idx' and '.reg'  properties to 'x' and 'r' respectively
# - changed xr argument to a vararg, to allow for whitespace in input

.include "./punkpc/xev.s"
  .macro idxr, xr:vararg; .irp s,len,beg,dep,end,idx,reg; idxr.\s=-1;.endr;
    .irpc c,\xr; idxr.len=idxr.len+1
      .ifc (,\c; idxr.dep=idxr.dep+1;
        .if idxr.dep==0; idxr.beg=idxr.len+1; idxr.end=-1; .endif; .endif
      .ifc ),\c; idxr.dep=idxr.dep-1; .if idxr.dep==-1; idxr.end=idxr.len-1; .endif; .endif
    .endr; xev 0,idxr.beg-2,\xr; idxr.x=xev; xev idxr.beg,idxr.end,\xr; idxr.r=xev;.endm
.endif
