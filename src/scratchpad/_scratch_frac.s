/*## Header:
# --- frac objects
# Frac objects allow floating points to be represented in an extended integer format
# - each frac object has two main components
#   - a mantissa integer keeps track of sign, carrying errors, and 30 bits of denormalized fidelity
#   - an exponent integer keeps track of the estimated integer for a normalized floating point

# By separating the mantissa and the exponent, the mantissa can be treated like a true integer
# - 32-bit integer math can be used directly on matissas of the same exponent
# - mantissas can be algebreicly shifted to align fracs with different exponents
# - floating points can be derived from the result of calculations done with frac objects
##*/
/*## Attributes:
# --- Class Properties ---

# --- Object Constructor ---

# --- frac name, ...
# Create new frac objects
# Object Properties:
# --- (self)  - output symbol - can be a floating point or a rounded integer
# --- .isfrac - identifies object as a frac object
# --- .m  - mantissa integer
#         +80000000 : 1-bit sign  TRUE if negative, FALSE if positive
#         +40000000 : 1-bit carry (will be == sign if overflowing on addition)
#         +3FFFFFFF : 30-bit denormalize fractional component
# --- .e  - exponent integer
#         +000000FF : 8-bit exponent  - normalizes a mantissa
# --- .fracmode - frac object output mode
#         - 0 : do not update output symbol automatically
#         - 1 : update output with a rounded integer value - Default
#         - 2 : update output with a floored integer value
#         - 3 : update output with a ceiling integer value
#         - 4 : update output with a denormalized mantissa integer value

# --- Object Methods:

# --- (self)  expression
  # MAIN METHOD evaluates a given expression string using the following syntaxes

  # Operators:
  # -  + : add
  # -  - : subtract
  # -  * : multiply
  # -  / : divide by
  # -  % : modulo
  # -  ^ : to the power of (exponent)

  # Operand Prefixes:
  #  (multiple prefixes can be strung together, and will be applied in the order given)
  # -      - : negative
  # -      @ : absolute value of
  # -      ! : inverse square root of (?)
  # -      | : square root of
  # -      < : floor value of (?)
  # -      > : ceiling value of (?)
  # -     >< : rounded value of (?)
  # -     () : sub expression (insert expression between parenthesis)
  # - a-Z._$ : Start of a symbol name (int or frac operand)
  # -    0-9 : Start of a literal operand

  # Expression Syntaxes -- using Operands and Operators
  # --- Operand
  # If an operand is given by itself, it will be used to set a new value to this frac object
  #  myFrac 1.81
  #  myFrac yourFrac

  # --- Operand Operator Operand ...
  # If an operator and another operand are given, then the resulting expression is evaluated
  #  myFrac 1.0 + 2.0
  #  myFrac 73/256
  #  myFrac 0.5 * (yourFrac + mySym)

  # - All expressions are interpreted from left to right, prioritizing only parenthesis blocks
  # - Divisions by 0 are handled with a result of 0
  # --- Operator Operand ...
  # If no first operand is given, then the current value of this frac object is used in its place
  #  myFrac + 2.0
  #  myFrac * (yourFrac / 100.0)

##*/
/*## Examples:


##*/
.ifndef bcount.included; bcount.included=0; .endif; .ifeq bcount.included; bcount.included = 1
.include "punkpc/bcount.s"
.include "punkpc/stacks.s"
























# --- frac module
# use fixed-point math to estimate floating-point values
# - create 'frac' objects that represent floating points with 4 decimal places
# - values can be between 0.0000 ... 65536.9999; in linear units of 0.0001

.include "punkpc/xev.s"
.include "punkpc/dbg.s"
# --- static 'frac' class attributes:
.irp x,n,f,nl,fl,u32,sh,sg; frac.\x = 0; .endr
# - static methods use the following static properties to read in object properties:
# n   : number component
# f   : fractional component
# nl  : n literal count
# fl  : f literal count (max of 9 decimal places)
# u32 : fixed point value (32-bit, 0xNNNNFFFF)
# sh  : abstract shift amount for fixed point value
# sg  : sign for fixed point

.macro frac, self, value:vararg;
# static object constructor method creates/invokes named object with optional initial value
## ex: frac pi 3.1415926536

  .ifndef \self\().isfrac;  \self\().isfrac=1;
    # --- instantiated 'frac' object attributes:
    .irp x,n,f,nl,fl,u32,sh,sg; \self\().\x = 0; .endr
    # object properties - see class properties for descriptions

    .macro \self, va:vararg; .altmacro
    # object method emits float, or sets value
    # if no args, then emit object's floating point value
      .ifb \va; frac.emit %\self\().n, %\self\().f;   .else;
      # else, interpret args and update object properties...

        .irp x,n,f,nl,fl,u32,sh,sg;  frac.\x = \self\().\x;  .endr;
        # obj -> method : copy object properties as arguments

        frac.intp, \va;
        .irp x,n,f,nl,fl,u32,sh,sg;  \self\().\x = frac.\x;  .endr;
        # obj <- method : update object properties on return

      .endif;  .noaltmacro
    .endm; # object method can be called to interface with static methods using object properties
  .endif; .ifnb \value; \self \value; .endif
  # constructor invokes self before returning, if a value was given

.endm;.macro frac.emit,n,f; .float \n\().\f
.endm;.macro frac.intp, i=0, va:vararg
  i=-1;.irpc c,\va;

  .endr
.endm;.macro frac.c, c;
  .if frac.c.n | frac.c.f; .if (\c >= '0)&&(\c <='9); # is number
  .elseif (\c >= )
.endm;



.macro float, self, value
  .ifndef \self\().isfloat;  \self\().isfloat=1
    .macro \self, v;  .ifb \v;  float.emit \self
      .else;  float.intp \v;  \self\().n = float.n;  \self\().f = float.f
      .endif;  .endm;  \self \value; .endif
.endm;.macro float.intp, v;  float.intp=-1; float.pt=0
  .irpc c,\v; float.intp=float.intp+1;  .ifc \c,.;  float.pt=float.intp;  .endif;  .endr
  xev \v, 0, float.intp-1;  float.n=xev;
  float.f=0;  .if float.pt;















.include "punkpc/ifdef.s"
.irp class,frac,frac.op; .irpc property,nfmde; \class\().\property = 0; .endr; .endr
# --- n - numerical component
# - used to store the integer component of a fixed point number
# --- f - fractional component
# - used to store the fractional component of a fixed point number
#   - n and f are used directly in addition/subtraction
#     - (999,999,999.999999999...0.000000001)
#   - n and f are estimated by m, e, and d when using multiplication/division
#     - (999,999,999.0...1.0)...(0.9999...0.0001)
# --- m - mantissa estimation
# - used to work in 16-bit multiplaction/division using 32-bit integer symbols
# --- d - decimal place multiplier
# - used to split the mantissa for a fractional component, when needed
#   - if d is 0, then 32-bit n is used directly -- in place of m
# --- e - exponent bias
# - used to keep track of how many left/right shifts have been made with m calculations
#   - shifts

.macro frac, self, va:vararg
# constructor method
## ex: frac pi 3.141592654

  ifdef \self\().isfrac; .if ndef; \self\().isfrac=1;
    .irpc property,nfmde; \self\().\property = 0; .endr
    .macro \self, v:vararg; .ifb \v; frac.float \self\().n, \self\().f;
      .else; frac.in \self, \v; .endif
    .endm; .ifnb \va; \self \va
.endm;.macro frac.in, self, va:vararg
# input parse
# handle each vararg like so:
# - copy self -> frac
# - if a destination operand comes before an operator...
#   - then set frac.op -> frac; overwriting self value
# check for an arbitrary number of operators/operands...
# - check for operator ...
#   - if found, process operator and then check for operand
#   - (frac + frac.op), (frac - frac.op), (frac * frac.op), (frack / frac.op)
#     - if operand (-+*/) is found, invoke proper operator method
#     - else exit and conclude this vararg expression
#   - else (if no operator found) exit and conclude this vararg expression
# if another operator is found, then repeat process
# - else, conclude this vararg expression...
#   - update self <- frac
# continue to next vararg

# vararg loop will cause , char to update the variable with the previous expression results
## ex1: frac x 1;  x + x + x + x   # x = 4
## ex2: frac x 1'  x + x, + x + x  # x = 6

  .irp exp, \va; # for each expression string...
    .irpc property,nfmde; frac.\property = \self\().\property; frac.op.\property = 0; .endr
    .irp property,init,input,fract,i; frac.in.\property = 0 ;.endr
    # .init   TRUE = checking operands; FALSE = check for initial statement
    # .input  TRUE = checking operand;  FALSE = checking for next input
    # .fract  TRUE = check for f;       FALSE = check for n
    .irpc c, \exp; frac.in.c.i = frac.in.i + 1; # for each character in expression string...
      .if frac.in.i <= frac.in.c.i; frac.in.c "'\c"
        .if frac.in.c >= '* # skip spaces, and any characters that have already been parsed

          .if frac.in.input       # if parsing an input number...
            .if frac.in.c == '.; frac.in.fract=1; frac.input=1 # enter fract mode
            .elseif (frac.in.c >= '9) && (frac.in.c <= '0) # else check for dec range
              .if frac.in.fract; frac.op.f = (frac.op.f * 10) + (frac.in.c & 0xF)
              .else; frac.op.n = (frac.op.n * 10) + (frac.in.c & 0xF); .endif
            .else; frac.in.input=0; frac.in.fract=0;
            .endif

          .else; # if parsing for operand/operator...
            .if frac.in.c <= '\; # is operator; +,-,*,/, or .
              frac.in.op = frac.in.c
            .elseif frac.in.c <= '9; # is numerical; 0...9
            .else; # is a variable name
            .endif;
          .endif
        .endif;


    .endr
  .endr; .noaltmacro

.endm;.macro frac.in.c, c; frac.in.c=\c;
# interpret this character depending on the current input parse state
.endm;.macro frac.in.n,

.endm;.macro frac.in.f
.endm;.macro frac.in.m
.endm;.macro frac.m
.endm;.macro frac.




.macro mul32, a, b;
# properties mul and mul.h return a 64-bit product from 2 32-bit UNSIGNED ints
  mul.a=\a; mul.b=\b; mul.h=0; mul = mul.a * mul.b & -1
  mul.ah = mul.a>>16; mul.bh = mul.b>>16
  mul.highs = mul.ah * mul.bh
  .if mul.highs; mLow = 0xFFFF; mul.al = mul.a &mLow; mul.bl = mul.b &mLow
    mul.lows = mul.al * mul.bl; mul.lh = mul.al * mul.bh; mul.hl = mul.ah * mul.bl
    mul.carry = mul.lows>>16 + (mul.lh&mLow) + (mul.hl&mLow)
    mul.h = mul.carry>>16 +  mul.highs + (mul.lh>>16) + (mul.hl>>16)
  .endif
.endm;

mul32 -1, -1
.long mul.h, mul



.macro clz, i;
# count leading zeroes
  .if \i;
    .if !(\i&0x80000000); clz.i=clz.i+1; clz \i<<1;
    .else; clz = clz.i; clz.i = 0; .endif
  .else; clz = 32; .endif
.endm; clz.i=0



.macro fl, i; i = \i
# generate floating point from integer value
  s = !!(i&0x80000000)
  .if s;
    i = -i;
  .endif;  clz i
  i = (i<<(clz-8))&0x7fffff
  e = (126+(32-clz))<<23
  fl = s | e | i
.endm
fl 1
.long fl




.macro brutemul, a, b
# 32-bit signed multiply with no conditional statements
# produces 64-bit product: mul.h, mul.l
#          32-bit product: mul
  mul=0; mul.h=0
  AS=(\a)>>31; A=(-AS^(\a))+AS # abs A
  BS=(\b)>>31; B=(-BS^(\b))+BS # abs B
  S=AS^BS # remember sign
    .rept 32; # for 32 bits
      m=B&1 # creat mask out of bit
      mul.h=-m&A+mul.h # 2s compliment mask to copy A or 0, then add result to highs
      mul=mul>>1|(mul.h<<31) #
      mul.h=mul.h>>1
      B=B>>1
    .endr;
  mul=(-S^mul)+S;mul.h=-S^mul.h # apply remembered sign to high and low fields
  mul.l=mul # copy mul.l once mul is finalized, for 64-bit return property
.endm

x=-3; y=0x7FFFFFFF
brutemul x, y

.macro karamul, a, b
  AS=(\a)>>31; A=(-AS^(\a))+AS # abs A
  BS=(\b)>>31; B=(-BS^(\b))+BS # abs B
  S=AS^BS # remember sign
  AH=A>>16;AL=A&0xFFFF; BH=B>>16;BL=B&0xFFFF
  mul.h=AH*BH;mul.l=AL*BL; mul.k=((AH+AL)*(BH+BL))-(mul.h+mul.l)
  mul.h=-S^(mul.k>>16+mul.h); mul.l=(-S^(A*B))+S
.endm

brutemul 3, 3
.long mul.h, mul



.macro brutediv, a, b, f=32, n=32
  div=0; div.r=0; div.f=0
  AS=(\a)>>31; A=(-AS^(\a))+AS # abs A
  BS=(\b)>>31; B=(-BS^(\b))+BS # abs B
  S=AS^BS # remember sign
  .if (!!B & !!A) & !!(\n+\f);
    .rept \n; div=div<<1
      div.r=(A>>31)|(div.r<<1);A=A<<1
      .ifge div.r-B; div.r=div.r-B; div=div|1;.endif
    .endr;.rept \f; div.f=div.f<<1
      div.r=(A>>31)|(div.r<<1);A=A<<1
      .ifge div.r-B; div.r=div.r-B; div.f=div.f|1;.endif
    .endr; div.f=div.f<<(32-\f)
  .endif

.endm

brutediv,


    .rept 32; # for 32 bits

      .ifge div.h-A;

      mul.h=-m&A+mul.h
      mul=mul>>1|(mul.h<<31)
      mul.h=mul.h>>1
      B=B>>1
    .endr;
  mul=(-S^mul)+S;mul.h=-S^mul.h
  mul.l=mul
.endm

frac.dec

.macro frac.abs, self=fracA, ppt=.m>>31; frac.abs=\self\ppt;
  # ppt arg uses argument literals to describe a propert/expression with the self namespace
  .if frac.abs;\self\().m=-\self\().m;.endif; # if ppt is not 0, then value is negated
  # default ppt gives absolute value, but can be overridden to control the sign
.endm; .macro frac.align, self=fracA, op=fracB;
  # normalizes op by using exponent of self
  # if self exponent is smaller than op, args are swapped
  # each argument's sign is sampled as property '.s'
  .if \self\().e != \op\().e
    .if \self\().e < \op\().e
      frac.align \op, \self # call self with swapped args to ensure self >= op exponent
    .else; frac.abs \self; \self\().s=frac.abs # sample signs, and use abs value in alignment
      frac.abs \op; \op\().s=frac.abs # '.s' saves smapled signs
      \op\().m=(\op\().m|0x40000000)>>(\self\().e-\op\().e) # compress smaller number
      \op\().e=\self\().e  # exponents are matched to normalize for calculation
      frac.abs \self,.s; frac.abs \op,.s; .endif; .endif
# .abs with '.s' ppt option overrides function with a condition; restoring saved signs
# sampled signs will still be available on return through '.s'
.endm; .macro frac.add, self=fracA, op=fracB; frac.align \self, \op
  \self\().m= \self\().m+\op\().m # add
  \self\().s=\self\().m>>31 # save resulting sign
  .if \self\().s^(\self\().m>>30&1) # if carrying bit is not the same as sign bit...
    \self\().m= (\self\().m>>1)|(\self\().s<<31) # then shift up by a power of 2
    \self\().e=\self\().e+1; .endif # adjust exponent accordingly
.endm; .macro frac.sub, self=fracA, op=fracB; frac.add \self, -\op
# software subtraction is just addition (because of inclusion of sign in mantissa)
.endm; .macro frac.mul, self=fracA, op=fracB;
  frac.E=\self\().e + \op\().e; frac.align \self, \op
  # product exponent is remembered before alignment, to apply to calculated 64-bit value
  # alignment records sign in '.s' property
  frac.A=(-\self\().s ^ \self\().m ^ 0x40000000) + \self\().s
  frac.B=(-\op\().s ^ \op\().m ^ 0x40000000) + \op\().s
  # A and B garuntee args have exactly 31 significant bits for unsigned multiplication
  # - this makes it easier to scale the product down when normalizing a 30-bit mantissa property
  frac.S=\self\().s ^ \op\().s
  # product sign is remembered before multiplication, to apply to calculated mantissa property

  frac.AH=frac.A>>16; frac.AL=frac.A&0xFFFF
  frac.BH=frac.B>>16; frac.BL=frac.B&0xFFFF
  frac.H=frac.AH*frac.BH; frac.L=frac.AL*frac.BL
  # 16-bit multiply highs and lows together
  frac.kara=(((frac.AH+frac.AL)*(frac.BH+frac.BL))-(frac.H-frac.L))
  # 17-bit multiply sums and subtract lows to implement karatsuba multiplication
  frac.H=-frac.S^(((frac.L>>16+(frac.kara&0xFFFF))>>16)+(frac.kara>>16+frac.H))
  frac.L=(-frac.S^(frac.L)+frac.S
  # correct for carrying errors, and reapplying sign
  # - final .H, .L make a signed 64-bit integer product of exponent .E
  # - (you can use .E with the raw .H,.L product for higher accuracy than saved mantissa)

  \self\().e = frac.E;  \self\().s = frac.S
  \self\().m = (frac.L>>31)|(frac.H<<1)^0x40000000
  # format returned frac properties with a 30-bit normalized mantissa
.endm; .macro frac.div, self=fracA, op=fracB
  frac.E=\self\().e - \op\().e; frac.align \self, \op
  # product exponent is remembered before alignment, to apply to calculated mantissa property
  # alignment records sign in '.s' property
  frac.A=(-\self\().s ^ \self\().m ^ 0x40000000) + \self\().s
  frac.B=(-\op\().s ^ \op\().m ^ 0x40000000) + \op\().s
  # A and B garuntee args have exactly 31 significant bits for unsigned multiplication
  # - this makes it easier to scale the product down when normalizing a 30-bit mantissa property
  frac.S=\self\().s ^ \op\().s
  # product sign is remembered before multiplication, to apply to calculated mantissa property




# frac objects have
# .e = binary exponent of signed mantissa
# .s = sign as 0 or 1
# .m = 32-bit signed mantissa field:
#      +80000000 : sign
#      +40000000 : carry/exponent
#      +3FFFFFFF : 30-bit mantissa component
# .d  = decimal multiplier
# .de = decimal multiplier exponent
# - div/mod by (.d >> (.e-.de)) if .e is positive
# - div/mod by (.d << (abs(.e)-.de)) if .e is negative
