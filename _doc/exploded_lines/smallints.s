.ifndef extr.included
  extr.included=0
.endif;
.ifeq extr.included
  extr.included = 1
  .macro extr rA,  rB,  mask=0,  i=32,  dot
    .if \mask
      .ifeq (\mask)&1
        extr \rA, \rB, (\mask)>>1, \i-1, \dot
      .else;
        rlwinm\dot \rA, \rB, (\i)&31, \mask
      .endif;
    .else;
      li \rA, 0
    .endif;
  .endm;
  .macro extr.,  rA,  rB,  m
    extr \rA, \rB, \m, , .
  .endm;
  .macro insr rA,  rB,  mask=0,  i=0,  dot
    .if \mask
      .ifeq (\mask)&1
        insr \rA, \rB, (\mask)>>1, \i+1, \dot
      .else;
        rlwimi\dot \rA, \rB, (\i)&31, \mask<<(\i&31)
      .endif;
    .endif;
  .endm;
  .macro insr.,  rA,  rB,  m
    extr \rA, \rB, \m, , .
  .endm;
.endif;

