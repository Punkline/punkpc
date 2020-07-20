.ifndef ld.included
  ld.included=0
.endif;
.ifeq ld.included
  ld.included = 1
  .include "./punkpc/xem.s"
  .macro load,  va:vararg
    ld \va
  .endm;
  .irp x,  bufa,  bufb,  bufi,  len,  w,  em,  strinput,  opt
    ld.\x=0
  .endr;
  .macro ld,  r=-31,  va:vararg
    ld.rev=0
    i=0
    ld.str=0
    .irpc c,  \r
      .ifc \c,  -
        ld.rev=1
      .endif;
      .exitm
    .endr;
    .if ld.rev
      ld.va (-(\r)), \va
    .else;
      ld.va \r, \va
    .endif;
  .endm;
  .macro ld.va,  r,  a,  va:vararg
    .ifnb \a
      ld.strinput=0
      .irpc c,  "\a"
        .if ld.strinput
          ld.ch "'\c"
        .else;
          .ifc \c,  >
            ld.strinput=1
            ld.str=ld.str+1
            i=0
          .else;
            .exitm
          .endif;
        .endif;
      .endr;
      .if ld.strinput
        .rept (4-i)&3
          ld.ch 0
        .endr;
      .else;
        ld.buf \a
      .endif;
      ld.va \r, \va
    .else;
      ld.w=ld.bufi
      ld.bufi=-1
      ld.len=ld.w<<2
      .rept ld.w
        ld.bufi=ld.bufi+1
        .if ld.rev
          ld.em \r-ld.bufi
        .else;
          ld.em ld.bufi+\r
        .endif;
      .endr;
    .endif;
  .endm;
  .macro ld.ch,  c
    i=(i+1)&3
    .if i&1
      ld.bufa=(ld.bufb<<8)|(\c&0xFF)
    .else;
      ld.bufb=(ld.bufa<<8)|(\c&0xFF)
    .endif;
    .ifeq i
      ld.buf ld.bufb
      ld.bufb=0
    .endif;
  .endm;
  .macro ld.buf,  i
    xem ld.buf$, ld.bufi, "<=\i>"
    ld.bufi=ld.bufi+1
  .endm;
  .macro ld.em,  r
    xem "<ld.em=ld.buf$>", ld.bufi
    .if ld.opt
      .if (ld.em>=-0x7FFF)&&(ld.em<=0x7FFF)
        li \r, ld.em
      .else;
        lis \r, ld.em@h
        .if (ld.em&0xFFFF)
          ori \r, \r, ld.em@l
        .endif;
      .endif;
    .else;
      lis \r, ld.em@h
      ori \r, \r, ld.em@l
    .endif;
  .endm;
.endif;

