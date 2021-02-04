# --- Index (Register)
#>toc library
# - index (register) input extraction tool
# - useful for simulating load/store syntaxes, like `lwz r3, 0x20(r30)`

# --- Updates:
# version 0.0.2:
# - refactored namespace to fit module name
# - refactored '.idx' and '.reg'  properties to 'x' and 'r' respectively
# - changed xr argument to a vararg, to allow for whitespace in input
# version 0.0.1
# - added to punkpc module library

# --- Class Properties

# --- idxr.x  - extracted index value
# --- idxr.r  - extracted register value



# ---Class Methods

# --- idxr  x(r)
# extract an index value and a register value from an input argument
# x  : becomes idxr.x value
# r  : becomes idxr.r value
# - right-most parentheses '( )' captures 'r'





## Binary from examples:

## 00000400 0000001F
## 00000400 0000001F.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module idxr, 2
.if module.included == 0; punkpc xev


  idxr.r=0
  .macro idxr, xr:vararg; .irp s,len,beg,dep,end,idx,reg; idxr.\s=-1;.endr;
    .irpc c,\xr; idxr.len=idxr.len+1
      .ifc (,\c; idxr.dep=idxr.dep+1;
        .if idxr.dep==0; idxr.beg=idxr.len+1; idxr.end=-1; .endif; .endif
      .ifc ),\c; idxr.dep=idxr.dep-1; .if idxr.dep==-1; idxr.end=idxr.len-1; .endif; .endif
    .endr; xev 0,idxr.beg-2,\xr; idxr.x=xev; xev idxr.beg,idxr.end,\xr; idxr.r=xev;.endm
.endif
