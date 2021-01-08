/*## Header:
# --- Mutable Behaviors
# Can be used in class modules to facilitate a mutable callback system for objs/classes
# Class-designed mutators can be formally registered as 'modes'
# User-designed mutators can be plugged in to override hooks implemented inside of object methods
# - class-level defaults can be used for new objects made by constructors
# - object-level defaults can be purged and redefined
# --- NOTE: Mutator names are case insensitive!
#   - if 2 macros of the same name in different cases are made, they will conflict
#   - this is not true of symbol names, so definitions are not able to detect this

##*/
##/* Updates:
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



##*/
/*## Attributes:

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
  # --- .hook        hook, obj  - construct mutator hooks
  # --- .mut   mut,  hook, obj  - mutate hook with unregistered mutation callback
  # --- .mode  mode, hook, obj  - mutate hook with a registered mode keyword
  # These all pass  class, hook_ns,  and  mut_ns  to corresponding corresponding 'mut.*' methods
  # - they are constructed by the mut.class method

  # --- .mut   obj, hook_ns
  # Alternative form of the .mut method will initialize an object
  # - if 'hook_ns' is blank, object hooks namespaces will use '\obj.hook.*' as a namespace
  # - this is a shorthand for calling 'mut.obj'

  # --- .call  obj, hook, mode, ...
  # Use this to invoke a hook with a fallback default mode to use if the hook doesn't exist
  # - if a hook is not initialized, purged, or otherwise disabled -- 'mode' is used instead
  # - if 'mode' is blank, the mode keyword 'default' is used to defer to a default mutator
  # - args in '...' are passed in the resulting call




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
  # --- .is_mutator_mode - instance of Mutator Mode Callback Object




## Binary from examples:

## 00000000 00000000
## 00000001 00000001
## 00001337 00000002
## 00001338 00000003
## 00001338 00000004
## 00000001 00000002
## 00000003 00000003
## 00001337 00000005
## 0000266E 00000006
## FFFFD992 00000007
## 00000007 00000100
## 00000101 00000100
## 00000200 00000180

##*/
/*## Examples:
.include "punkpc.s"
punkpc mut
# Use the 'punkpc' statement to load this module, or include the module file directly



# --- MUTABLE BEHAVIOR HOOKS ---


mut.class myClass
# This makes it possible to use class-level mutator constructors when building object constructors
# - these constructors help facilitate the implementation of mutator hooks


# Let's make the class constructor use a mutable behavior:

.macro myClass, self
  # this is an example of a constructor macro will make objects of the class 'myClass'
  # - it's just a macro definition containing initializations for the object 'self'

  \self = 0
  # This is an example of a property belonging to this object, 'self'
  # - it is given the initial value of 0

  .macro \self; \self\().hook.myBehavior; .endm
  # This is an example of a method belonging to this object
  #   it has been given its own object name, so we can just treat the object like a method
  # - it's a nested macro definition that calls a 'hook' named 'myBehavior'
  # - the argument of \self is passed to the behavior as an argument
  #   - this lets the behavior reference the object namespace, and access its attributes

  myClass.mut \self
  # 'myClass' was given this method when we called 'mut.class' earlier
  # --- we call this to make \self a 'mutable object', making it easier to mutate 'myBehavior'
  # - this will add  '.hook', '.mut',  and  '.mode'  methods to this object that we can use later

  \self\().hook myBehavior
  # we can use the '.hook' method this creates to initialize the hook for 'myBehavior'
  # - calling this will cause the default behavior 'myClass.mut.myBehavior' to be mapped to it
  # --- we can mutate this at any time after the object is constructed

.endm
# now the constructor definition is finished
#   by calling 'myClass' we can construct new objects of the name given as 'self'
#   - calling them as methods will invoke the 'myBehavior' hook we just set up in the constructor


# Now let's make a default behavior, for our hook:

.macro myClass.mut.myBehavior.default, self;  \self = \self + 1; .endm
# This is an example of a class-level default behavior
# - it simply adds 1 to the property given to this object
# - this is what will be invoked by the hook in our generated objects
# --- The naming convention is as follows:
# --- myClass    - this is the name of the class we gave to 'mut.class'
# --- mut        - this is a default namespace that gets used if we don't specify it in 'mut.class'
# --- myBehavior - this is a keyword used to refer to this hook in the object
# By following this naming mechanism, you can define any number of default 'hook' behaviors
# - this is useful, because it is done at the class level and only needs to be initialized in objs


# Finally, lets test the behavior:

myClass x
myClass y
# Create a pair of objects called 'x' and 'y'
# - a method and property are generated for each of these, by the constructor macro we invoked

.long x, y
# >>> 00000000 00000000
# the property of x and y can be referenced like any other symbol

x; y
# we can call 'x' and 'y' like statements to invoke our programmed behavior

.long x, y
# >>> 00000001 00000001
# the behavior had this effect on the property: self = self + 1



# --- BEHAVIOR MUTATORS ---


# Now, let's change the behavior of 'x'

.macro myMutation, self; \self = 0x1337; .endm
# this mutation will change the behavior of 'myBehavior' if we apply it as a mutator to that hook

x.mut myMutation, myBehavior
# this causes the default behavior we assigned to 'myBehavior' to be replaced with 'myMutation'


# 'x' is now a mutant, with a mutated behavior:

x; y
.long x, y
# >>> 00001337 00000002
# --- x invoked its mutation - but y maintained its old behavior

# With mutators, it's possible to change the behavior of an object AFTER it is constructed
# - this lets you play with polymorphism in your class object designs


x.hook myBehavior
# by invoking the '.hook' mutator method, you can reset 'myBehavior' back to its default behavior

x; y
.long x, y
# >>> 00001338 00000003
# x is now back to its old self


x.mut, myBehavior
# by mutating with a blank name, you can cause the behavior to turn into a NO-OP

x; y
.long x, y
# >>> 00001338 00000004
# Now the x method does nothing at all



# --- MUTATOR MODES ---


# You can make a set of mutators designed as part of a class module with mutator modes
# This is almost just like setting up a default behavior, except that you can add many behaviors

.macro myClass.mut.myBehavior.shift,    self; \self = \self << 1; .endm
.macro myClass.mut.myBehavior.negate,   self; \self = -\self; .endm
.macro myClass.mut.myBehavior.subtract, self; \self = \self - 1; .endm
# these are 3 example mutation modes that we can apply to myBehavior
# - each can be identified using just the last keyword in their object namespace
#   - 'shift', 'negate', and 'subtract'

x.mode myBehavior, shift, negate, subtract
# By using '.mode' at the object level, we can register multiple modes in a single call
# - now, each of these modes have been mapped to 'myBehavior' and can be referenced by keywords

.irp kw, shift, negate, subtract; .long myClass.mut.myBehavior.\kw; .endr
# >>> 1, 2, 3
# These are the mode IDs assigned to the keywords you have registered

.long x.hook.myBehavior.mode
# >>> 3
# This is the currently selected mode. It corresponds with 'subtract' -- the last applied keyword

x; y
.long x, y
# >>> 00001337 00000005
# - subtraction mode subtracted from x

x.mode myBehavior, shift
x; y
.long x, y
# >>> 0000266E 00000006

x.mode myBehavior, negate
x; y
.long x, y
# >>> FFFFD992 00000007




# --- EMPTY HOOK CALLS ---

# You may implement hooks at the class-level inside of object methods
# - this helps reduce the number of hook instances necessary in objects configured to be 'default'

mut.class otherClass
.macro otherClass, self

  \self = 0
  .macro \self; otherClass.call_hook \self, myBehavior; .endm
  otherClass.mut \self
  otherClass.purge_hook \self, myBehavior
  # We have initialized the 'myBehavior' hook, but we have not instantiated its method
  # - this causes it to be flagged in a way that '.call_hook' will recognize
  # - the default mode will be used to catch this case, even though a hook method doesn't exist

.endm

.macro otherClass.mut.myBehavior.default, self;  \self = \self - 1; .endm
# This is the default mode that otherClass objects will default to when no hook is available

otherClass z
# 'i' is an instance of 'otherClass' that we can use like 'x' and 'y'

z = 10
z; z; z
.long z
# >>> 00000007
# The default hook behavior is used despite there being no hook method!




# --- ALTERNATIVE NAMESPACES ---

mut.class int, cb
# --- the second argument 'cb' - creates the namespace 'int.cb' instead of 'int.mut'

.macro int, self;
  int.mut \self, op
  # --- the second arg 'op' - creates the namespace 'self.op' instead of 'self.hook'
  # - now, any objects constructed at the \self (object) level will use this namespace

  \self = 0
  \self\().hook incr, decr
  .macro \self, va:vararg
    .ifnb \va
      .ifc \va, ++; \self\().op.incr; .exitm; .endif
      .ifc \va, --; \self\().op.decr; .exitm; .endif
      \self = \self \va
    .endif # if ++ or --, then trigger 'op' hooks;  else, just apply args to end of assignment
  .endm
.endm
# This constructs 'int' objects, which are easy to increment or decrement with a shorthand syntax

.macro int.cb.incr.default, self; \self = \self + 1; .endm
.macro int.cb.incr.word, self; \self = \self + 4; .endm
.macro int.cb.incr.double, self; \self = \self << 1; .endm
.macro int.cb.decr.default, self; \self = \self - 1; .endm
.macro int.cb.decr.word, self; \self = \self - 4; .endm
.macro int.cb.decr.double, self; \self = \self >> 1; .endm
# Some default behaviors, with alternative modes 'word' and 'double'

int i
i = 0x100
.long i
# >>> 00000100
# A normal symbol assignment

i++
.long i
# >>> 00000101
# ... but it's an object that we can invoke like a statement, too!
# - the '++' invokes the special 'incr' behavior we set up, which adds 1 to the value

i--
.long i
# >>> 00000100

i.mode incr, double
i++
.long i
# >>> 00000200
# Now 'i' will increment by doubling

i.mode decr, word
.rept 32; i--; .endr
.long i
# >>> 00000180


##*/
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
