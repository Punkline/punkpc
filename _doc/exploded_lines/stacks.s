.ifndef stack.included
  stack.included=0
.endif;
.ifeq stack.included
  stack.included = 0x100
  .include "./punkpc/sidx.s"
  .include "./punkpc/ifdef.s"
  .include "./punkpc/ifalt.s"
  .include "./punkpc/mut.s"
  stack.fill = 0
  stack.size = 0
  stack.sss = 1<<31-1
  stack$ = 0
  stack.idx = 0
  stack.oob = 0
  mut.class stack
  .macro stack,  self,  varg:vararg
    ifdef \self\().isStack
    .if ndef
      stack$=stack$+1
      \self\().isStack=stack$
      \self\().s = size
      ifdef \self
      .if ndef
        \self = stack.fill
      .endif;
      \self\()$0 = \self\().fill
      .irp ppt,  s,  ss,  i,  pop,  q,  qq,  deq,  iter
        \self\().\ppt=0
      .endr;
      \self\().fill = stack.fill
      \self\().step = 1
      \self\().init = stack.size
      \self\().sss = stack.sss
      .if \self\().init > 0
        .altmacro
        stack.fill \self, 0, \self\().size, \self\().fill
        .noaltmacro
      .endif;
      .macro \self\().s,  idx=\self\().ss
        \self\().s=\idx
        .if \idx > \self\().ss
          \self\().s=\self\().ss
        .endif;
      .endm;
      .macro \self\().ss,  idx=\self\().ss
        \self\().s=\idx
        .if \idx > \self\().sss
          \self\().s = \self\().sss
        .endif;
        .if \idx > \self\().ss
          \self\().ss=\self\().s
        .endif;
      .endm;
      .macro \self\().q,  idx=\self\().qq
        \self\().q=\idx
        .if \idx < \self\().qq
          \self\().q=\self\().qq
        .endif;
      .endm;
      .macro \self\().i,  va:vararg=0
        \self\().hook.idx_i \self, \va
      .endm;
      .macro \self\().get,  idx=\self\().i,  sym=\self,  va:vararg
        \self\().i = \idx - 1
        .irp x,  \sym,  \va
          \self\().i = \self\().i + 1
          .ifnb \x
            sidx.get \self, \self\().i
            \x = sidx
            \self\().hook.get_plugin \self, \x
          .endif;
        .endr;
      .endm;
      .macro \self\().set,  idx=\self\().i,  val=\self,  va:vararg
        \self\().i = \idx - 1
        .irp x,  \val,  \va
          \self\().i = \self\().i + 1
          .ifnb \x
            sidx = \x
            sidx.set \self, \self\().i
            \self\().hook.set_plugin \self, \x
          .endif;
        .endr;
      .endm;
      .macro \self\().new,  size=1,  fill=\self\().fill
        stack.fill \self, \self\().ss+1, \size, \fill
      .endm;
      .macro \self\().reset,  fill,  start=\self\().qq,  size=\self\().init
        stack.reset \self, \fill, \start, \size
      .endm;
      .macro \self\().push,  va:vararg=\self
        stack.push \self, \va
      .endm;
      .macro \self\().pop,  va:vararg=\self\().pop
        stack.pop \self, \va
      .endm;
      .macro \self\().popm,  va:vararg
        \self\().pop
        .ifnb \va
          stack.pop \self, \va
        .endif;
      .endm;
      .macro \self\().deq,  va:vararg=\self\().deq
        stack.deq \self, \va
      .endm;
      .macro \self\().iter,  va:vararg=\self
        stack.iter \self, \va
      .endm;
      .macro \self\().push.mode,  kw
        \self\().mode oob_push, \kw
      .endm;
      .macro \self\().pop.mode,  kw
        \self\().mode oob_pop, \kw
      .endm;
      .macro \self\().deq.mode,  kw
        \self\().mode oob_deq, \kw
      .endm;
      .macro \self\().iter.mode,  kw
        \self\().mode oob_iter, \kw
      .endm;
      .macro \self\().i.mode,  oob,  idx
        .ifnb \oob
          \self\().mode oob_i, \oob
        .endif;
        .ifnb \idx
          \self\().mode idx_i, \idx
        .endif;
      .endm;
      stack.mut \self
      \self\().push.mode incr
      \self\().pop.mode null
      \self\().deq.mode null
      \self\().iter.mode rot
      \self\().i.mode rot, range
      \self\().mut , i_plugin, get_plugin, set_plugin, iter_plugin, push_pre, push_post
    .endif;
    .ifnb \varg
      stack \varg
    .else;
      .irp ppt,  fill,  size,  
        stack.\ppt = 0
      .endr;
    .endif;
  .endm;
  .macro stack.fill,  self,  start,  size,  fill
    LOCAL i, idx
    idx = \start
    i = \size
    .if \self\().sss < (idx+i)
      i = \self\().sss - idx
    .endif;
    .if (idx <= \self\().ss) && (\self\().ss < (idx+i))
      \self\().ss = idx+i
    .endif;
    .if i > 0
      .rept i
        sidx.ema \self, %idx, <=\fill>
        idx=idx+1
      .endr;
    .endif;
  .endm;
  .macro stack.reset,  self,  fill,  start,  size
    \self\().q = \start
    \self\().s = \self\().q + \size
    .ifnb \fill
      stack.fill \self, \self\().q, \size, \fill
    .endif;
    .if \self\().q < \self\().qq
      \self\().q = \self\().qq
    .endif;
    .if \self\().s > \self\().ss
      \self\().s = \self\().ss
    .endif;
  .endm;
  .macro stack.push,  self,  va:vararg
    ifalt
    stack.memalt = alt
    .altmacro
    .irp val,  \va
      .ifnb \val
        \self\().hook.push_pre \self, \val
        .if \self\().s < \self\().sss
          .if \self\().s >= \self\().ss
            stack.oob=1
            \self\().hook.oob_push \self, \val
          .endif;
          .if stack.oob==0
            sidx.ema \self, %\self\().s, <=\val>
            \self\().s = \self\().s + 1
            \self = \self\().fill
            \self\().hook.push_post \self, \val
          .endif;
        .endif;
      .endif;
      stack.oob=0
    .endr;
    ifalt.reset stack.memalt
    stack.oob=0
  .endm;
  .macro stack.pop,  self,  va:vararg
    ifalt
    stack.memalt = alt
    .altmacro
    .irp sym,  \va
      .ifnb \sym
        .if \self\().s <= \self\().q
          stack.oob=1
          \self\().hook.oob_pop \self, \sym
        .endif;
        .if stack.oob==0
          \self\().pop = \self
          \sym = \self
          \self\().s = \self\().s - 1
          sidx.ema <\self = \self>, %\self\().s
        .endif;
      .endif;
      stack.oob=0
    .endr;
    ifalt.reset stack.memalt
    stack.oob=0
  .endm;
  .macro stack.deq,  self,  va:vararg
    stack.memalt = alt
    .altmacro
    .irp sym,  \va
      .ifnb \sym
        stack.oob=0
        .if \self\().q+1 >= \self\().s
          stack.oob=1
          \self\().hook.oob_deq \self, \sym
        .endif;
        .if stack.oob==0
          sidx.ema <\self\().deq=\self>, %\self\().q
          \sym = \self\().deq
          \self\().q = \self\().q + 1
        .endif;
      .endif;
      stack.oob=0
    .endr;
    ifalt.reset stack.memalt
    stack.oob=0
  .endm;
  .macro stack.iter,  self,  va:vararg
    .irp sym,  \va
      .ifnb \sym
        stack.idx = \self\().i + \self\().step
        .if stack.idx >= \self\().s
          stack.oob=1
        .elseif stack.idx < \self\().q;
          self.oob=1
        .endif;
        .if stack.oob
          \self\().hook.oob_iter \self, \sym
        .endif;
        .if stack.oob==0
          \self\().i = stack.idx
          \self\().iter = \self
          \sym = \self
          \self\().get
          \self\().hook.iter_plugin \self, \sym
        .endif;
      .endif;
      stack.oob=0
    .endr;
    stack.oob=0
  .endm;
  .macro stack.mut.oob_push.nop,  self,  va:vararg
    stack.oob=0
  .endm;
  .macro stack.mut.oob_pop.nop,  self,  va:vararg
    stack.oob=0
  .endm;
  .macro stack.mut.oob_deq.nop,  self,  va:vararg
    stack.oob=0
  .endm;
  .macro stack.mut.oob_iter.nop,  self,  va:vararg
    stack.oob=0
  .endm;
  .macro stack.mut.oob_push.rot,  self,  sym,  va:vararg
    \self\().s = \self\().qq
    stack.oob = 0
    .if \self\().q > \self\().s
      \self\().q = \self\().s
    .endif;
  .endm;
  .macro stack.mut.oob_pop.rot,  self,  sym,  va:vararg
    \self\().s = \self\().ss
    stack.oob = 0
  .endm;
  .macro stack.mut.oob_deq.rot,  self,  sym,  va:vararg
    sidx.ema <\self\().deq=\self>, %\self\().q
    \sym = \self\().deq
    \self\().q = \self\().qq
  .endm;
  .macro stack.mut.oob_iter.rot,  self,  sym,  va:vararg
    stack.idx = stack.idx - \self\().q
    stack.oob=0
    .if stack.idx
      stack.idx = stack.idx % (\self\().s - \self\().q)
    .endif;
    .if stack.idx < 0
      stack.idx = \self\().s + stack.idx
    .else;
      stack.idx = stack.idx + \self\().q
    .endif;
  .endm;
  .macro stack.mut.oob_push.incr,  self,  va:vararg
    \self\().ss = \self\().s + 1
    stack.oob = 0
  .endm;
  .macro stack.mut.oob_push.step,  self,  va:vararg
    \self\().ss = \self\().s + \self\().step
    \self\().s = \self\().s + \self\().step - 1
    stack.oob = 0
  .endm;
  .macro stack.mut.oob_pop.null,  self,  sym,  va:vararg
    \sym = \self
    \self = \self\().fill
  .endm;
  .macro stack.mut.oob_deq.null,  self,  sym,  va:vararg
    .if \self\().q == \self\().s
      \sym=\self\().fill
      \self\().deq = \sym
    .else;
      sidx.ema <\self\().deq=\self>, %\self\().q
      \sym = \self\().deq
      \self\().reset, , 0
    .endif;
  .endm;
  .macro stack.mut.oob_iter.null,  self,  sym,  va:vararg
    \sym = \self
    \self = \self\().fill
  .endm;
  .macro stack.mut.oob_pop.cap,  self,  va:vararg
    \self\().s = \self\().q+1
    stack.oob=0
  .endm;
  .macro stack.mut.oob_deq.cap,  self,  va:vararg
    \self\().q = \self\().s-1
    stack.oob=0
  .endm;
  .macro stack.mut.oob_iter.cap,  self,  va:vararg
    \self\().i = \self\().s-\self\().step
    stack.oob=0
  .endm;
  .macro stack.mut.idx_i.range,  self,  idx,  va:vararg
    \self\().hook.oob_i \self, (\idx + \self\().q)
    \self\().hook.i_plugin \self, \idx, \va
  .endm;
  .macro stack.mut.idx_i.rel,  self,  idx,  va:vararg
    \self\().hook.oob_i \self, (\idx + \self\().i)
    \self\().hook.i_plugin \self, \idx, \va
  .endm;
  .macro stack.mut.idx_i.abs,  self,  idx,  va:vararg
    \self\().hook.oob_i \self, \idx
    \self\().hook.i_plugin \self, \idx, \va
  .endm;
  .macro stack.mut.oob_i.nop,  self,  idx,  va:vararg
    \self\().i = \idx
  .endm;
  .macro stack.mut.oob_i.rot,  self,  idx,  va:vararg
    \self\().i = \idx - \self\().q
    .if \self\().i
      \self\().i = \self\().i % (\self\().s - \self\().q)
    .endif;
    .if \self\().i < 0
      \self\().i = \self\().s + \self\().i
    .else;
      \self\().i = \self\().i + \self\().q
    .endif;
  .endm;
  .macro stack.mut.oob_i.cap,  self,  idx,  va:vararg
    \self\().i = \idx
    .if \self\().i >= \self\().s
      \self\().i = \self\().s - 1
    .endif;
    .if \self\().i < \self\().q
      \self\().i = \self\().q
    .endif;
  .endm;
.endif;

