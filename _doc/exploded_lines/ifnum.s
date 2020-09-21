.ifndef ifnum.included
  ifnum.included = 0
.endif;
.ifeq ifnum.included
  ifnum.included = 1
  num=0
  nnum=1
  .macro ifnum,  n
    num=0
    .irpc c,  \n
      .irpc d,  0123456789
        .ifc \c,  \d
          num=1
          .exitm
        .endif;
      .endr;
      .exitm
    .endr;
    nnum=num^1
  .endm;
.endif;

