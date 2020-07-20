/*## Header:
# --- ld or load: LoaD immediate(s) - ld [reg], [value or string], [next value or string]...
#  can load multiple values or strings into a sequence of registers
#  strings should be quoted, and must begin with a '>' character for recognition
#  - number of instructions is minimized using optional evaluations (see extra note)
#  if [reg] is positive, that register will be the base of an incrementing register number
#  if [reg] starts with the literal char '-', the reg number is used with a decrementor instead
#  if [reg] is blank, a default of decrementing r31 is used to complement lmw/stmw syntax

##*/
/*## Attributes:
# --- Class Properties ---

# --- ld.len  - returns length of last output (in bytes)
# --- ld.opt  - optimization flag
# - if True, (default) then fewer instructions are used to generate input, if possible
#   - this mode is not capable of handling undefined expressions (like forward label math)
# - if False, number of instructions used is not optimized
#   - this mode does not evaluate undefined expressions, and thus supports them


# --- Class Methods ---

# --- ld  reg, arg, ...
# Loads (multiple, if needed) 32-bit immediates in 1 or 2 instructions
# reg : register value, but has 3 methods of interpretation:
#       - if positive, register will be the base of an incrementing register number
#          ex: 3 =  r3, r4, r5, r6      for a 16-byte value
#       - if reg literally starts with a '-' char, this becomes a decrementer instead
#          ex: 31 = r31, r30, r29, r28  for a 16-byte value
#       - if blank, then a default of decrementing r31 is used to compliment lmw/stmw syntax
# arg : can be be either a value or a string that starts with '>'
# ... : multiple 32-bit args or variable-length strings can be loaded at once, in register sequence

# --- load reg, arg, ...
# - an alias for ld

##*/
/*## Examples:
.include "./punkpc/ld.s"

li r0, 1
ld r0, 1; load r0, 1
# 'ld' works like 'li'. 'load' is an alias.
ld r4, 0x804019F4, ">Hello World!"
stswi r5, r4, ld.len-4
# 'ld' can handle 32-bit values, multiple arguments, and even strings that start with '>'
#  the 'ld.len' property saves the byte size taken up in the registers


# --- a note about ld evaluations:
# ld.opt=0 by default
# if ld.opt==0, 'ld' will not optimize the number of instructions used
#  - when not optimized, expressions with missing definitions can be used as values
#  - otherwise, default requires that all given expressions are evaluable
# this scenario is most commonly an issue with label math:

_back=.
ld.opt=0;  ld r0, _forward-_back
# 'ld' can handle expressing '_forward' before it is defined, but uses 2 instructions to do so
_forward=.
ld.opt=1;  ld r0, _forward-_back
# optimized 'ld' uses only 1 instruction, but needs to be used after '_forward' is evaluable
# if tried before '_forward' is defined, the value will stay 0 until the linker handles it
#   - when not using the linker, this may be useful for creating null terminators

##*/

.ifndef ld.included; ld.included=0; .endif; .ifeq ld.included; ld.included = 1
.include "./punkpc/xem.s"
  .macro load,va:vararg;ld \va;.endm;
  .irp x,bufa,bufb,bufi,len,w,em,strinput,opt;ld.\x=0;.endr;
  .macro ld,r=-31,va:vararg; ld.rev=0;i=0;ld.str=0;
    .irpc c,\r;.ifc \c,-;ld.rev=1;.endif;.exitm;.endr;
    .if ld.rev;ld.va (-(\r)),\va;.else;ld.va \r,\va;.endif;.endm;
  .macro ld.va,r,a,va:vararg;
    .ifnb \a;ld.strinput=0;
      .irpc c,"\a";
        .if ld.strinput; ld.ch "'\c";
        .else; .ifc \c,>; ld.strinput=1; ld.str=ld.str+1; i=0;.else;.exitm;.endif;.endif;.endr;
      .if ld.strinput; .rept (4-i)&3; ld.ch 0;.endr;.else;ld.buf \a;.endif;
      ld.va \r,\va;
    .else;ld.w=ld.bufi;ld.bufi=-1;ld.len=ld.w<<2;
        .rept ld.w; ld.bufi=ld.bufi+1;
          .if ld.rev;ld.em \r-ld.bufi;.else;ld.em ld.bufi+\r;.endif;
        .endr;.endif;.endm;
  .macro ld.ch,c;i=(i+1)&3;
    .if i&1;ld.bufa=(ld.bufb<<8)|(\c&0xFF);.else;ld.bufb=(ld.bufa<<8)|(\c&0xFF);.endif;
    .ifeq i;ld.buf ld.bufb;ld.bufb=0;.endif;
  .endm;.macro ld.buf,i;xem ld.buf$,ld.bufi,"<=\i>";ld.bufi=ld.bufi+1;
  .endm;.macro ld.em,r;xem "<ld.em=ld.buf$>",ld.bufi;.if ld.opt;
      .if (ld.em>=-0x7FFF)&&(ld.em<=0x7FFF);li \r,ld.em;.else;lis \r,ld.em@h;.if (ld.em&0xFFFF);
  ori \r,\r,ld.em@l;.endif;.endif;.else;lis \r,ld.em@h;ori \r,\r,ld.em@l;.endif;.endm;
.endif
/**/
