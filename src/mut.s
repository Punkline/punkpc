.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module mut, 3
.if module.included == 0; punkpc ifdef

  mut.mutable_class$ = 0
  mut.mutable_obj$   = 0
  mut.mutator$      = 0
  mut.mutable_mode$  = 0
  mut.uses_obj_mut_methods = 1

  # static class-level constructor methods:

  .macro mut.class, class, mut_ns=mut, hook_ns=hook
    # make class-level mutator building methods for a given class
    # - pass namespaces to this call for the class definition

    ifdef \class\().is_mutable_class
    .if ndef; mut.mutable_class$ = mut.mutable_class$ + 1
      \class\().is_mutable_class=mut.mutable_class$
      ifdef \class\().uses_obj_mut_methods
      .if ndef; \class\().uses_obj_mut_methods = mut.uses_obj_mut_methods; .endif

      # instantiated class-level constructor methods:
      .macro \class\().hook, hook, obj
        mut.hook \hook, \obj, \class, \mut_ns, \hook_ns

      .endm; .macro \class\().mut, mut, hook, obj
      # --- if only 'mut' is given, it becomes 'self' in an object constructor
      # if only 1 arg, assume it's an obj that needs to be given mutator construction methods

        .ifb \obj; .ifnb \hook; mut.obj \mut, \class, \mut_ns, \hook;
          .else; mut.obj \mut, \class, \mut_ns, \hook_ns; .endif
        .else; mut.mut \mut, \hook, \obj, \hook_ns; .endif

      .endm; .macro \class\().mode, mode, hook, obj;
        mut.mode \mode, \hook, \obj, \class, \mut_ns, \hook_ns

      .endm; .macro \class\().call_\hook_ns, obj, hook, mode=default, va:vararg
        mut.call \obj, \hook, \mode, \class, \mut_ns, \hook_ns, \va

      .endm; .macro \class\().purge_hook, obj, va:vararg
        .irp hook, \va; mut.purge_hook \hook, \obj, \hook_ns; .endr

      .endm
    .endif



  .endm; .macro mut.obj, obj, class, mut_ns=mut, hook_ns=hook
    # make object-level mutator building methods for a given class object
    # - pass namespaces to this call from the object constructor

    ifdef \obj\().is_mutable_obj
    .if ndef; mut.mutable_obj$ = mut.mutable_obj$ + 1
      \obj\().is_mutable_obj = mut.mutable_obj$
      .if \class\().uses_obj_mut_methods

        # instantiated object-level mutator methods, if using them:

        .macro \obj\().hook, va:vararg
          .irp hook, \va; mut.hook \hook, \obj, \class, \mut_ns, \hook_ns; .endr

        .endm; .macro \obj\().mut, mut, va:vararg
          .irp hook, \va; mut.mut  "\mut", \hook, \obj, \hook_ns; .endr

        .endm; .macro \obj\().mode, hook, va:vararg
          .irp mode, \va; mut.mode \mode, \hook, \obj, \class, \mut_ns, \hook_ns; .endr
        .endm
      .endif
    .endif



  .endm; .macro mut.hook, hook, obj, class, mut_ns=mut, hook_ns=hook
    # make hooks to default behaviors that can be changed (mutated) later on
    mut.purge_hook \hook, \obj, \hook_ns
    .macro \obj\().\hook_ns\().\hook, va:vararg;
      \class\().\mut_ns\().\hook\().default \obj, \va
    .endm; \obj\().\hook_ns\().\hook\().purgable = 1
    # hooks connect to the mut_ns namespace in order to init or re-init default behaviors



  .endm; .macro mut.mut, mut, hook, obj, hook_ns=hook
    # mutate a hook by giving it the name of a macro to execute in place of old behavior
    mut.purge_hook \hook, \obj, \hook_ns
    .ifb \mut; .macro \obj\().\hook_ns\().\hook, va:vararg; .endm  # make a NOP if mutator is blank
    .else;     .macro \obj\().\hook_ns\().\hook, va:vararg; \mut \obj, \va; .endm; .endif
    \obj\().\hook_ns\().\hook\().purgable = 1
    # mutations connect an existing hook to an alternative behavior



  .endm; .macro mut.mode, mode=default, hook, obj, class, mut_ns=mut, hook_ns=hook
    # mutate a hook by giving it the name of a registered 'mode' keyword, for specialized mutations

    mut.purge_hook \hook, \obj, \hook_ns  # ready hook for overwrite
    ifdef \class\().\mut_ns\().\hook\().mode$
    .if ndef; \class\().\mut_ns\().\hook\().mode$ = 0; .endif
    ifdef \class\().\mut_ns\().\hook\().\mode\().is_mutator_mode
    # validate mutator mode keyword...

    .if ndef; mut.mutable_mode$ = mut.mutable_mode$ + 1
      \class\().\mut_ns\().\hook\().\mode\().is_mutator_mode = mut.mutable_mode$
      \class\().\mut_ns\().\hook\().mode$ = \class\().\mut_ns\().\hook\().mode$ + 1
      \class\().\mut_ns\().\hook\().\mode = \class\().\mut_ns\().\hook\().mode$
    .endif # if not a valid mode, then register it as a new mode

    .macro \obj\().\hook_ns\().\hook, va:vararg;
      \class\().\mut_ns\().\hook\().\mode \obj, \va
    .endm
    \obj\().\hook_ns\().\hook\().mode  = \class\().\mut_ns\().\hook\().\mode
    \obj\().\hook_ns\().\hook\().purgable = 1
    # re-define hook event using given mutation mode keyword as an extension of hook namespace


  .endm; .macro mut.call, obj, hook, mode, class, mut_ns=mut, hook_ns=hook, va:vararg
    .if \obj\().\hook_ns\().\hook\().purgable; \obj\().\hook_ns\().\hook \va
    .else; \class\().\mut_ns\().\hook\().\mode \obj, \va; .endif


  .endm; .macro mut.purge_hook, hook, obj, hook_ns=hook
    # this will purge an existing hook, or initialize it if it hasn't been registered yet
    # - purged hooks can be manually overwritten, if desired
    #   - re-purging the hook later will allow the overwrite to be overwritten, or further modded
    ifdef \obj\().\hook_ns\().\hook\().is_mutator
    .if def; .if \obj\().\hook_ns\().\hook\().purgable; .purgem \obj\().\hook_ns\().\hook; .endif
    # purge the hook if it is purgable
    .else; mut.mutator$ = mut.mutator$ + 1
      \obj\().\hook_ns\().\hook\().is_mutator = mut.mutator$
      \obj\().\hook_ns\().\hook\().mode = 0
      # each registered mode gets an ID, which can be read from this '.mode' property
      # - when an unregistered mode is in use, mode = 0
      #   - at this time in development, this includes the default class behavior
    .endif

    \obj\().\hook_ns\().\hook\().mode = 0
    \obj\().\hook_ns\().\hook\().purgable = 0
    # nullify mode ID, and set purgable flag to false

  .endm
.endif
