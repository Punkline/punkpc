.ifndef bcount.included;  bcount.included=0;.endif;
.ifeq bcount.included;  bcount.included = 1
  .macro bcount.zbe,  i;  bcount = 0;bcount.int = \i;bcount.len = 32
    .if !bcount.int;  bcount = 32
    .else;  .rept 5;  bcount.len = bcount.len >> 1
        .if !(bcount.int >> (32-bcount.len))
          bcount.int = bcount.int << bcount.len
          bcount = bcount + bcount.len;.endif;.endr;.endif;
  .endm;.macro bcount.zle,  i;  bcount = 0;bcount.int = \i;bcount.len = 32
    .if !bcount.int;  bcount = 32
    .else;  .rept 5;  bcount.len = bcount.len >> 1
        .if !(bcount.int << (32-bcount.len))
          bcount.int = bcount.int >> bcount.len
          bcount = bcount + bcount.len;.endif;.endr;.endif;
  .endm;.macro bcount.be,  i;  bcount.zle \i;bcount = 32-bcount
  .endm;.macro bcount.le,  i;  bcount.zbe \i;bcount = 32-bcount
  .endm;.macro bcount,  i;  bcount.zbe \i;bcount = 32-bcount
  .endm;.macro bcount.signed,  i;  bcount.sign = \i>>31
    .if (\i==-1)||(\i==0);  bcount = 2
    .else;  .if bcount.sign;  bcount.le ~\i
      .else;  bcount.le \i;.endif;bcount=bcount+1;.endif;
  .endm;.macro bcount.zsigned,  i;  bcount.signed \i;bcount = 32 - bcount
  .endm;.endif;

