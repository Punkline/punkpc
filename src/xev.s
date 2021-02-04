# --- Extract Evaluation Tool
#>toc library
# - for extracting evaluable literals from 2 known character indices in a given string argument
# - useful when parsing complex inputs for evaluable sub-expressions

# --- Updates:
# version 0.0.1
# - added to punkpc module library

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
#   string : a string to extract a range of characters from.ifndef punkpc.library.included; .include "punkpc.s"; .endif
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
