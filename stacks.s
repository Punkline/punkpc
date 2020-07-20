.ifndef stack.included;  stack.included=0;.endif;
.ifeq stack.included;  stack.included = 2
  .include "./punkpc/sidx.s"
  .include "./punkpc/ifdef.s"
  stack.fill = 0;stack.size = 0;stack.sss = 1<<31-1
  stack$ = 0
  .macro stack.fill,  stack,  start,  size,  fill;  LOCAL i, idx
    idx = \start;i = \size
    .if \stack\().sss < (idx+i)
      i = \stack\().sss - idx;.endif;
    .if (idx <= \stack\().ss) && (\stack\().ss < (idx+i))
      \stack\().ss = idx+i;.endif;
    .if i > 0
      .rept i;  sidx.ema \stack, %idx, <=\fill>
        idx=idx+1;.endr;.endif;
  .endm;.macro stack.oob,  stack,  method,  behavior;  .purgem \stack\().oob.\method
    .macro \stack\().oob.\method,  va:vararg;  stack.cb.oob.\method\().\behavior \stack, \va
    .endm;.endm;.macro stack,  self,  varg:vararg;  ifdef \self\().isStack
    .if ndef;  stack$=stack$+1;\self\().isStack=stack$;\self\().s = size;ifdef \self
      .if ndef;  \self = stack.fill;.endif;\self\()$0 = \self\().fill
      .irp ppt,  s,  ss,  pop,  q,  qq,  deq;  \self\().\ppt=0;.endr;
      \self\().fill = stack.fill;\self\().init = stack.size;\self\().sss = stack.sss
      .if \self\().init > 0
        .altmacro;stack.fill \self, 0, \self\().size, \self\().fill;.noaltmacro;.endif;
      .macro \self\().s,  idx=\self\().ss;  \self\().s=\idx
        .if \idx > \self\().ss
          \self\().s=\self\().ss;.endif;
      .endm;.macro \self\().q,  idx=\self\().qq;  \self\().q=\idx
        .if \idx < \self\().qq
          \self\().q=\self\().qq;.endif;
      .endm;.macro \self\().topget,  sym=\self,  va:vararg
        sidx.noalt2 "<.ifdef \self>", \self\().s, "<;\sym=\self>", \self\().s, "<;.else;\sym=\self.fill;.endif>"
        .irp v,  \va
          .ifnb \v;  \v=\sym;.endif;.endr;
      .endm;.macro \self\().topset,  val=\self;  sidx.noalt \self, \self\().s, "< = \val>"
      .endm;.macro \self\().new,  size=1,  fill=\self\().fill
        stack.fill \self, \self\().ss+1, \size, \fill
      .endm;.macro \self\().reset,  fill,  start=\self\().qq,  size=\self\().init
        \self\().q = \start;\self\().s = \self\().q + \size
        .ifnb \fill;  stack.fill \self, \self\().q, \size, \fill;.endif;
        .if \self\().q < \self\().qq
          \self\().q = \self\().qq;.endif;
        .if \self\().s > \self\().ss
          \self\().s = \self\().ss;.endif;
      .endm;.macro \self\().push,  va:vararg=\self;  .altmacro
        .irp val,  \va
          .if \self\().s < \self\().sss
            .if \self\().s > \self\().ss
              \self\().oob=1;\self\().oob.push \val
              .if \self\().oob;  .exitm;.endif;.endif;
            sidx.ema \self, %\self\().s, <=\val>
            \self\().s = \self\().s + 1;\self = \self\().fill;.endif;.endr;.noaltmacro
      .endm;.macro \self\().pop,  va:vararg=\self\().pop;  .altmacro
        .irp sym,  \va
          .if \self\().s <= \self\().q
            \self\().oob=1;\self\().oob.pop \sym
            .if \self\().oob;  .exitm;.endif;.endif;\self\().pop = \self;\sym = \self
          \self\().s = \self\().s - 1;sidx.ema <\self = \self>, %\self\().s
        .endr;.noaltmacro
      .endm;.macro \self\().deq,  va:vararg=\self\().deq;  .altmacro
        .irp sym,  \va
          .if \self\().q+1 >= \self\().s
            \self\().oob=1;\self\().oob.deq \sym
            .if \self\().oob;  .exitm;.endif;.endif;
          sidx.ema <\self\().deq=\self>, %\self\().q
          \sym = \self\().deq;\self\().q = \self\().q + 1;.endr;.noaltmacro
      .endm;.macro \self\().oob.push,  va:vararg;  .endm;.macro \self\().push.mode,  m
        stack.oob \self, push, \m
      .endm;.macro \self\().oob.pop,  va:vararg;  .endm;.macro \self\().pop.mode,  m
        stack.oob \self, pop, \m
      .endm;.macro \self\().oob.deq,  va:vararg;  .endm;.macro \self\().deq.mode,  m
        stack.oob \self, deq, \m
      .endm;\self\().push.mode incr;\self\().pop.mode null;\self\().deq.mode null;.endif;
    .ifnb \varg;  stack \varg
    .else;  .irp ppt,  fill,  size,  ;  stack.\ppt = 0;.endr;.endif;
  .endm;.macro stack.cb.oob.push.nop,  stack,  va:vararg;  .endm;
  .macro stack.cb.oob.pop.nop,  stack,  va:vararg;  .endm;
  .macro stack.cb.oob.deq.nop,  stack,  va:vararg;  .endm;
  .macro stack.cb.oob.pop.null,  stack,  sym,  va:vararg;  \sym = \stack
    \stack = \stack\().fill
  .endm;.macro stack.cb.oob.deq.null,  stack,  sym,  va:vararg
    .if \stack\().q == \stack\().s;  \sym=\stack\().fill;\stack\().deq=\sym
    .else;  sidx.ema <\stack\().deq=\stack>, %\stack\().q
      \sym=\stack\().deq;\stack\().reset, , 0;.endif;
  .endm;.macro stack.cb.oob.push.incr,  stack,  va:vararg;  \stack\().ss=\stack\().s+1
    \stack\().oob=0
  .endm;.macro stack.cb.oob.pop.cap,  stack,  va:vararg;  \stack\().s = \stack\().q+1
    \stack\().oob=0
  .endm;.macro stack.cb.oob.deq.cap,  stack,  va:vararg;  \stack\().q = \stack\().s-1
    \stack\().oob=0
  .endm;.macro stack.cb.oob.pop.rot,  stack,  va:vararg;  \stack\().s = \stack\().ss
    \stack\().oob=0
  .endm;.macro stack.cb.oob.deq.rot,  stack,  sym,  va:vararg
    sidx.ema <\stack\().deq=\stack>, %\stack\().q
    \sym=\stack\().deq;\stack\().q = \stack\().qq
  .endm;.endif;

