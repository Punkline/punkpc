# --- xev [begin char idx], [inclusive end idx], [str]
# Extract eXpression and EValuate
#  substring is extracted from body and evaluated through the 'xev' property
/*## Examples:
xev 5,6,myVal16; .long xev
# expression '16' is extracted from symbol name 'myVal16'
xev 5,,myVal17; .long xev
# blank end index selects end of string
xev,,myVal18; .long xev
# blank beginning index reselects last used beginning index; or 0 default
# >>> 00000010 00000011 00000012
##*/

.ifndef xev.included; xev.included = 0; .endif; .ifeq xev.included; xev.included = 1
  .macro xev,b=xe.beg,e=-1,va:vararg;xe.beg=\b;xe.end=\e&(-1>>1);xe.len=xe.beg-1;xev=-1;xe.ch,\va
  .endm;.macro xe.ch,e,va:vararg;xe.i=-1;xe.len=xe.len+1;.irpc c,\va;xe.i=xe.i+1;.if xe.i>xe.end
    .exitm;.elseif xe.i>=xe.len;xe.ch "\e\c",\va;.endif;.endr;.if xev==-1;xev=\e;.endif
  .endm;.irp x,beg,end,len;xe.\x=0;.endr;xev=-1
.endif
/**/
