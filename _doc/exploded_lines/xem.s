.ifndef xem.included
  xem.included=0
.endif;
.ifeq xem.included
  xem.included = 1
  .macro xem,  p,  x,  s
    .altmacro
    xema \p, %\x, \s
    .noaltmacro
  .endm;
  .macro xema,  p,  x,  s
    \p\x\s
  .endm;
  x=-1
  .rept 32
    x=x+1
    .irpc c,  rfb
      xem \c, x, "<=x>"
    .endr;
    xem m, x, "<=1!<!<(31-x)>"
  .endr;
  sp=r1
  rtoc=r2
  x=-1
  .rept 8
    x=x+1
    xem cr, x, "<=x>"
    i=x<<2
    .irp s,  lt,  gt,  eq,  so
      \s=i&3
      xem cr, x, "<.\s=i>"
      i=i+1
    .endr;
  .endr;
.endif;

