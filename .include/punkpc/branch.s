.ifndef punkpc.library.included
  .include "punkpc.s";.endif;punkpc.module branch, 2
.if module.included == 0
  .ifndef branchl.purge;  branchl.purge = 0;.endif;
  .if branchl.purge;  branchl.purge = 0;.purgem branch;.purgem;branchl;.endif;
  .macro bla,  a,  b
    .ifb \b
      lis r0, \a @h
      ori r0, r0, \a @l
      mtlr r0
      blrl;.else;
      lis \a, \b @h
      ori \a, \a, \b @l
      mtlr \a
      blrl;.endif;
  .endm;.macro ba,  a,  b
    .ifb \b
      lis r0, \a @h
      ori r0, r0, \a @l
      mtctr r0
      bctr;.else;
      lis \a, \b @h
      ori \a, \a, \b @l
      mtctr \a
      bctr;.endif;
  .endm;.irp l,  l,  ,  
    .macro branch\l,  va:vararg;  b\l\()a \va
    .endm;.endr;.endif;

