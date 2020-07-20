.ifndef bla.included
  bla.included=1
  .macro bla,  a,  b
    .ifb \b
      lis r0, \a @h
      ori r0, r0, \a @l
      mtlr r0
      blrl
    .else;
      lis \a, \b @h
      ori \a, \a, \b @l
      mtlr \a
      blrl
    .endif;
  .endm;
  .macro ba,  a,  b
    .ifb \b
      lis r0, \a @h
      ori r0, r0, \a @l
      mtctr r0
      bctr
    .else;
      lis \a, \b @h
      ori \a, \a, \b @l
      mtctr \a
      bctr
    .endif;
  .endm;
  .irp l,  l,  ,  
    .macro branch\l,  va:vararg
      b\l\()a \va
    .endm;
  .endr;
.endif;

