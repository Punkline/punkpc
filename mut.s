.ifndef mut.included;  mut.included = 0;.endif;
.ifeq mut.included;  mut.included = 1
  .include "./punkpc/ifdef.s"
  mut.mutableClass$ = 0;mut.mutableObj$ = 0;mut.mutator$ = 0;mut.mutatorMode$ = 0
  .macro mut.class,  class,  mut_ns=mut,  hook_ns=hook;  ifdef \class\().isMutableClass
    .if ndef;  mut.mutableClass$ = mut.mutableClass$ + 1
      \class\().isMutableClass=mut.mutableClass$
      .macro \class\().hook,  hook,  obj;  mut.hook \hook, \obj, \class, \mut_ns, \hook_ns
      .endm;.macro \class\().mut,  mut,  hook,  obj
        .ifb \obj
          .ifnb \hook;  mut.obj \mut, \class, \mut_ns, \hook
          .else;  mut.obj \mut, \class, \mut_ns, \hook_ns;.endif;
        .else;  mut.mut \mut, \hook, \obj, \hook_ns;.endif;
      .endm;.macro \class\().mode,  mode,  hook,  obj
        mut.mode \mode, \hook, \obj, \class, \mut_ns, \hook_ns
      .endm;.endif;
  .endm;.macro mut.obj,  obj,  class,  mut_ns=mut,  hook_ns=hook;  ifdef \obj\().isMutableObj
    .if ndef;  mut.mutableObj$ = mut.mutableObj$ + 1;\obj\().isMutableObj = mut.mutableObj$
      .macro \obj\().hook,  va:vararg
        .irp hook,  \va;  mut.hook \hook, \obj, \class, \mut_ns, \hook_ns;.endr;
      .endm;.macro \obj\().mut,  mut,  va:vararg
        .irp hook,  \va;  mut.mut \mut, \hook, \obj, \hook_ns;.endr;
      .endm;.macro \obj\().mode,  hook,  va:vararg
        .irp mode,  \va;  mut.mode \mode, \hook, \obj, \class, \mut_ns, \hook_ns;.endr;
      .endm;.endif;
  .endm;.macro mut.hook,  hook,  obj,  class,  mut_ns=mut,  hook_ns=hook
    mut.purge \hook, \obj, \hook_ns
    .macro \obj\().\hook_ns\().\hook,  va:vararg;  \class\().\mut_ns\().\hook \va
    .endm;\obj\().\hook_ns\().\hook\().purgable = 1
  .endm;.macro mut.mut,  mut,  hook,  obj,  hook_ns=hook;  mut.purge \hook, \obj, \hook_ns
    .ifb \mut
      .macro \obj\().\hook_ns\().\hook,  va:vararg;  .endm;.else;
      .macro \obj\().\hook_ns\().\hook,  va:vararg;  \mut \va
      .endm;.endif;\obj\().\hook_ns\().\hook\().purgable = 1
  .endm;.macro mut.mode,  mode,  hook,  obj,  class,  mut_ns=mut,  hook_ns=hook
    mut.purge \hook, \obj, \hook_ns;ifdef \class\().\mut_ns\().\hook\().mode$
    .if ndef;  \class\().\mut_ns\().\hook\().mode$ = 0;.endif;
    ifdef \class\().\mut_ns\().\hook\().\mode\().isMutatorMode
    .if ndef;  mut.mutatorMode$ = mut.mutatorMode$ + 1
      \class\().\mut_ns\().\hook\().\mode\().isMutatorMode = mut.mutatorMode$
      \class\().\mut_ns\().\hook\().mode$ = \class\().\mut_ns\().\hook\().mode$ + 1
      \class\().\mut_ns\().\hook\().\mode = \class\().\mut_ns\().\hook\().mode$;.endif;
    .macro \obj\().\hook_ns\().\hook,  va:vararg;  \class\().\mut_ns\().\hook\().\mode \va
    .endm;\obj\().\hook_ns\().\hook\().mode = \class\().\mut_ns\().\hook\().\mode
    \obj\().\hook_ns\().\hook\().purgable = 1
  .endm;.macro mut.purge,  hook,  obj,  hook_ns=hook
    ifdef \obj\().\hook_ns\().\hook\().isMutator
    .if def
      .if \obj\().\hook_ns\().\hook\().purgable;  .purgem \obj\().\hook_ns\().\hook;.endif;
    .else;  mut.mutator$ = mut.mutator$ + 1
      \obj\().\hook_ns\().\hook\().isMutator = mut.mutator$
      \obj\().\hook_ns\().\hook\().mode = 0
      .macro \obj\().\hook_ns\().\hook\().mut,  mut;  mut.mut \mut, \hook, \obj, \hook_ns
      .endm;.macro \obj\().\hook_ns\().\hook\().mode,  mode;  \obj\().mode \hook, \mode
      .endm;.macro \obj\().\hook_ns\().\hook\().purge;  mut.purge \hook, \obj, \hook_ns
      .endm;.endif;\obj\().\hook_ns\().\hook\().mode = 0
    \obj\().\hook_ns\().\hook\().purgable = 0
  .endm;.endif;

