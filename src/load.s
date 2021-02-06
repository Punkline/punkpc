# --- Load Immediate(s)
#>toc ppc
# - a tool for creating multiple immediate loads
#   - immediates larger than 16-bits will require multiple instructions
#   - you can use this macroinstruction to string together as many as you need for a given input
# - useful for writing functions that load absolute addresses, ascii keywords, and other things

# --- Updates:
# version 0.0.3
# - renamed 'load.purge' to 'load.purgem', and set it to true when macros are defined
# version 0.0.2
# - renamed module to 'load', because old name was not appropriate
#   - old name 'ld' is a powerpc instruction not used in mgekko, and is dissimilar to this macro
# - added 'load.purge'
# version 0.0.1
# - added to punkpc module library

# --- Class Properties

# --- load.len  - returns length of last output (in bytes)
# --- load.opt  - optimization flag
# - if True, (default) then fewer instructions are used to generate input, if possible
#   - this mode is not capable of handling undefined expressions (like forward label math)
# - if False, number of instructions used is not optimized
#   - this mode does not evaluate undefined expressions, and thus supports them


# --- Class Methods

# --- load  reg, arg, ...
# Loads (multiple, if needed) 32-bit immediates in 1 or 2 instructions
# reg : register value, but has 3 methods of interpretation:
#        if positive, register will be the base of an incrementing register number
#        -  ex: 3 =  r3, r4, r5, r6      for a 16-byte value
#        if reg literally starts with a '-' char, this becomes a decrementer instead
#        -  ex: 31 = r31, r30, r29, r28  for a 16-byte value
#        if blank, then a default of decrementing r31 is used to compliment lmw/stmw syntax
# arg : can be be either a value or a string that starts with '>'
# ... : multiple 32-bit args or variable-length strings can be loaded at once, in register sequence.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module load, 3
.if module.included == 0; punkpc regs
.ifndef load.purgem; load.purgem = 0; .endif
.if load.purgem; .purgem load; .endif; load.purgem = 1
  .irp x,bufa,bufb,bufi,len,w,em,strinput;load.__\x=0;.endr; load.opt=1
  .macro load,r=-31,va:vararg; load.__rev=0;i=0;load.__str=0;
    .irp x,bufa,bufb,bufi,len,w,em,strinput;load.__\x=0;.endr;
    .irpc c,\r;.ifc \c,-;load.__rev=1;.endif;.exitm;.endr;
    .if load.__rev;load.__va (-(\r)),\va;.else;load.__va \r,\va;.endif;.endm;
  .macro load.__va,r,a,va:vararg;
    .ifnb \a;load.__strinput=0;
      .irpc c,"\a";
        .if load.__strinput; load.__ch "'\c";
        .else; .ifc \c,>; load.__strinput=1; load.__str=load.__str+1;
          i=0;.else;.exitm;.endif;.endif;.endr;
      .if load.__strinput; .rept (4-i)&3; load.__ch 0;.endr;.else;load.__buf \a;.endif;
      load.__va \r,\va;
    .else;load.__w=load.__bufi;load.__bufi=-1;load.len=load.__w<<2;
        .rept load.__w; load.__bufi=load.__bufi+1;
          .if load.__rev;load.__em \r-load.__bufi;.else;load.__em load.__bufi+\r;.endif;
        .endr;.endif;.endm;
  .macro load.__ch,c;i=(i+1)&3;
    .if i&1;load.__bufa=(load.__bufb<<8)|(\c&0xFF);
    .else;load.__bufb=(load.__bufa<<8)|(\c&0xFF);.endif;
    .ifeq i;load.__buf load.__bufb;load.__bufb=0;.endif;
  .endm;.macro load.__buf,i;xem load.__buf$,load.__bufi,"<=\i>";load.__bufi=load.__bufi+1;
  .endm;.macro load.__em,r;xem "<load.__em=load.__buf$>",load.__bufi;.if load.opt;
      .if (load.__em>=-0x7FFF)&&(load.__em<=0x7FFF);li \r,load.__em;.else;lis \r,load.__em@h;
      .if (load.__em&0xFFFF);ori \r,\r,load.__em@l;.endif;.endif;
      .else;lis \r,load.__em@h;ori \r,\r,load.__em@l;.endif;.endm;
.endif
/**/
