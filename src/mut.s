# --- Object Method Mutator Hooks
#>toc obj
# - a core module for defining mutable behavior hooks
# - useful for making your class/objects customizable
# - extended by the `obj` module

# --- Updates:
# Version 0.0.5
# - changed annoying order of arguments in class-level methods
#   - 'obj' now comes as first argument, as one might intuit
# Version 0.0.4
# - added '.uses_obj_mut_methods' flag to class and module levels
#   - flagging this as false will cause the affected class to generate objects with no mut methods
#   - this includes '.hook', '.mut', and '.mode'
#   - intended for objects meant to be operated entirely by class methods
# Version 0.0.3
# - object hooks now imply 'self' as the first argument, so it doesn't need to be passed each time
# - changed default mutator namespace to be reachable as a mode keyword, 'default'
#   - 'myClass.mut.myBehavior'   is now   'myClass.mut.myBehavior.default'
#     - this lets 'default' be used as a mode keyword
# Version 0.0.2
# - enquoted mutator argument in obj.mut method, allowing for prefix statements
# version 0.0.1
# - added to punkpc module library

# --- Class Properties

# --- mut.mutable_class$ -   class ID counter
# --- mut.mutable_obj$   -     obj ID counter
# --- mut.mutator$      - mutator ID counter
# --- mut.mutable_mode$  -    mode ID counter

# --- mut.uses_obj_mut_methods - temporary param that changes the next instantiated 'mut.class'




# --- Mutable Class ---
# For Mutable Classes
# - a class namespace for collecting static method and property attributes under

# --- mut.class      class, mut_ns, hook_ns
# Creates a small object at the class level of some other module, for constructing mutators
# - if the class 'mut_ns' is blank, class-default callbacks will use '\class.mut.*' as a namespace

# Class-default behaviors must be defined by (class).(mut_ns).(hook) macro definitions, by the user



  # - for (class) namespace...
  # --- Class Properties
  # --- .is_mutable_class     - instance of Mutatable class object
  # --- .uses_obj_mut_methods - flag for conditionally constructing obj-level methods in new objs
  # - flag can be set preemptively, before instantiating with 'mut.class'

  # --- Class Methods
  # --- .hook  obj,       hook  - construct mutator hooks
  # --- .mut   obj, mut,  hook  - mutate hook with unregistered mutation callback
  # --- .mode  obj, mode, hook  - mutate hook with a registered mode keyword
  # These all pass  class, hook_ns,  and  mut_ns  to corresponding corresponding 'mut.*' methods
  # - they are constructed by the mut.class method

  # --- .mut   obj, hook_ns
  # Alternative form of the .mut method will initialize an object
  # - if 'hook_ns' is blank, object hooks namespaces will use '\obj.hook.*' as a namespace
  # - this is a shorthand for calling 'mut.obj'

  # --- .call_hook  obj, hook, mode, ...
  # Use this to invoke a hook with a fallback default mode to use if the hook doesn't exist
  # - if a hook is not initialized, purged, or otherwise disabled -- 'mode' is used instead
  # - if 'mode' is blank, the mode keyword 'default' is used to defer to a default mutator
  # - args in '...' are passed in the resulting call

  # --- .purge_hook  obj, hook, ...
  # Use this to ensure that a hook has been initialized, and is available for instantiation





# --- Mutable Object ---
# For Mutable Objects
# - an object to be included inside of another class object constructor method
# - summarizes given 'hook_ns' and 'mut_ns' as internalized literals

# --- mut.obj   obj, class, mut_ns, hook_ns
# A class-level backend to handle constructing objects with object-level mutator constructor methods
# Object-level constructor calls are for initializing inside of another object constructor method
# The .hook method can be used to assign mutators



  # - for (obj) namespace...
  # --- Object Properties
  # --- .is_mutable_obj - instance of Mutable class object



  # --- Object Methods  --- only if class '.uses_obj_mut_methods' is true...  (true by default)

  # --- .hook  hook, ...
  # Register any number of hook names as new hooks for this object
  # - the type name must match a class-level mutator name to default to
  # - if hook has already been created, then this will cause it to reset back to class default

  # --- .mut   mut, hook, ...
  # Mutate hook to use given mutator callback macro
  # - callback name 'mut' does not have to be under a registered mode
  # - if 'mut' is blank, then hook becomes a nop
  # - if multiple hooks are given, then each hook will recieve the same callback
  #   - this is useful for assigning multiple nops, or a implementing common handlers
  # - if 'mut' is encapsulated in a quoted string, it may contain multiple statement prefixes
  #   - each statement must be delimited with a ';' semicolon

  # --- .mode  hook, mode ...
  # Register any number of mode names as new modes for specified hook belonging to this object
  # - these do not require class-level defaults, and will not have any effect until mutated
  # - if multiple modes are given, then they will all become registered for given hook



# --- Mutator Hook Object ---

# For Callable Mutator Hooks
# - a hook, as in a method that can be called like a callback event
# - call these hook objects from within another object method to implement a mutable event

# --- mut.mut   mut, hook, obj, hook_ns
# A class-level backend for abstract '.mut' methods
# - allows for assigning custom mutations
# - intended to be used at the object level, to imply most arguments
# --- mut.hook   hook, obj, class, mut_ns, hook_ns
# Alternative class-level backend for abstract '.hook' methods
# - only installs default (mutable) behaviors
#   - plugs into default mut_ns namespace for mutator callbacks to install with hook
#   - if mut_ns is blank, then the default is set to a common NOP callback

# --- mut.purge_hook  hook, obj, hook_ns
# Purges the given hook if it exists, and is purgable; registering any uninitialized hook keywords
# - will ensure that the given hook keyword is safe to overwrite, even if it doesn't exist yet
# This is technically the hook constructor, it's just used by the other mut.* constructors

# --- mut.call   obj, hook, mode, class, mut_ns, hook_ns, ...
# Use this to invoke a hook with a fallback default mode to use if the hook doesn't exist


  # - for (obj).(hook_ns).(hook) namespace...
  # --- Hook Properties
  # --- .is_mutator - instance of a Mutator Hook object
  # --- .mode$     - an incrementing ID counter, for assigning to new modes
  # --- .mode      - an ID for what registered mode this mutator is in - 0 if unregistered
  # --- .purgable  - a flag that informs the .purge_hook macro, for overwritting



  # --- Hook Method
  # --- (self)  ...
  # can be called to invoke mutable behavior




# --- Mutation Mode Callback Object ---
# For Mutation Mode Callbacks
# - mutations with keywords attached to the hook; these make a dictionary of callbacks

# --- mut.mode  mode, hook, obj, class, mut_ns, hook_ns
# A class-level backend to handle object-level '.mode' methods (see Mutable Class Object, above)
# - registers and uses input callback names as 'modes' that can be referenced by dictionary keyword
# - modes can be switched to easily at the user level, with provided object methods

  # - for (obj).(hook_ns).(hook).(mode) namespace...
  # --- Mode Properties
  # --- (self) - registered mode ID for this keyword
  # --- .is_mutator_mode - instance of Mutator Mode Callback Object.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module mut, 5
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
      .macro \class\().hook, obj, hook
        mut.hook \hook, \obj, \class, \mut_ns, \hook_ns

      .endm; .macro \class\().mut, obj, mut, hook
      # if only 'obj' is given, it becomes 'self' in an object constructor
      # if 'hook' is blank, 'mut' becomes the object constructor's hook namespace
      # else args work as named...

        .ifb \hook; .ifnb \mut; mut.obj \obj, \class, \mut_ns, \mut;
          .else; mut.obj \obj, \class, \mut_ns, \hook_ns; .endif
        .else; mut.mut \mut, \hook, \obj, \hook_ns; .endif

      .endm; .macro \class\().mode, obj, mode, hook;
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
