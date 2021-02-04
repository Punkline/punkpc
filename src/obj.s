# --- Objects (and Classes)
#>toc Modules : objects and classes
# - a core module for defining classes that construct objects
# - objects are uniquely named
# - unique objects may be given pointer IDs, for identifying instances of a class
# - object methods may be defined through hook callers, for creating mutable behaviors
#   - mutable object methods may be reached via pointers, at the class level
# - object properties may be given hidden names, used internally by the constructor



# --- Class Properties
# --- obj.class.uses_pointers  - use pointers by default
# --- obj.class.self_pointers  - don't point to self by default
# --- obj.class.uses_mutators  - use mutators by default
# --- obj.class.uses_obj_mut_methods - uses obj-level mutator methods by default, if using mutators
# - these flags only affect newly created object classes, not newly instantiated objects
#   - they can be edited from the class-level at any time

# --- obj.def
# --- obj.ndef
# - these return whether or not an object was defined or undefined before instantiation routine




# --- Constructor Methods

# There is a class-level constructor and an object-level constructor:

# --- obj.class     class, class_ppt, dict, get
# Creates class-level methods for setting up and accessing
# You must specify a class and a class_ppt name
# - the dict and get arguments are optional, and will default to the names 'point' and 'pointer'
#   - these are used to create method names/properties for




  # --- Class Object Properties
  # --- .is_objClass - keeps track of the number of instantiated classes that count pointers
  # --- .uses_pointers - flag enables/disables generation of pointer properties in .obj method
  # --- .self_pointers - flag enables/disables assignment of pointer value to 'self' property
  # --- .uses_mutators - flag enables/disabled use of mutators and method hooks
  # --- .uses_obj_mut_methods - flag enables/disables obj-level mutator methods, if using mutators
  # --- .\get - the pointer output property name -- called '.pointer' by default




  # --- Class Object Methods
  # --- .\dict  obj_point, macro, ...
  # By default, this is called '.point'
  # The pointer dictionary method, for accessing object name from a pointer value
  # Emits:   \macro  (name of object(s)), ...
  # - obj_point must be an object pointer for this class
  # - if quoted, multiple comma-separated pointer arguments can be given
  # - macro can be any macro or directive that can handle the object being pointed to

  # --- .\dict\()q obj_point, macro, ...
  # By default, this is called '.pointq'
  # This variation can queue the argument instead of stacking it when emitted:
  # Emits:   \macro  ..., (name of object(s)

  # --- .\get   obj, sym
  # By default, this is called '.pointer'
  # The pointer generation method, for copying pointer values to the output property
  #  'sym' is given the pointer as a return value
  # - obj can be an object, and object pointer, or just a number equal to a pointer value
  # - if sym is not provided, a property of the same name as the method is used
  #   - by default, this is '.pointer'

  # --- .call_method  obj, meth, ...
  # A callback that invokes an object's method, through pointers
  #  'obj' may be pointer value or the name of an actual object
  #  'meth' is the name of a method that trails the object name

  # --- .get_property  obj, ppt, sym
  # A callback that copies an object's property, through pointers
  #  'obj' may be pointer value or the name of an actual object
  #  'ppt' is the name of a property
  #  'sym' is the name of a symbol to copy the property to (if blank '.property' is used)

  # --- .set_property  obj, ppt, val
  # A callback that copies to an object's property, through pointers
  #  'obj' may be pointer value or the name of an actual object
  #  'ppt' is the name of a property
  #  'val' is an expression to assign to the property (if blank '.property' is used)

  # --- .meth          obj, method, ...
  # Instantiate methods that hook directly into default mutators of the same names
  # - these don't have to be given hook instances to function
  # 'obj' is the name of an object to create methods for
  #   - if blank, the methods are created for the class-level, instead
  # 'method' is the name of an object method

  # --- .call_\mut_ns  obj, hook, mode, ...
  # Call an object method without having to invoke the object directly
  # - if the hook instance isn't found, it will default to the given mode keyword
  # - otherwise, it will prioritize a found hook instance directing to a specific mutator

  # --- .obj           obj
  # The object instantiater method, for registering an object namespace and giving it a pointer
  # - obj can be any unused namespace that is appropriate for your class object



    # --- Object Properties
    # --- .\class_ppt - the property that holds an object pointer value for this object
    # - this can be checked to verify that this object namespace is associated with this class




# --- Class Methods

# --- obj.hidden_constructor  self, constructor, ...
# A special module-level method that passes a generated hidden namespace to a constructor
# - self is the name of the object to use
# - constructor is the name of the constructor macro that uses self and the hidden namespace
# - ... is any number of trailing args that should go to the constructor.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module obj, 2
.if module.included == 0; punkpc if, hidden, mut

obj.state.altm = alt
obj.state.alt = 0
objClasses$ = 0
obj.class.uses_pointers = 1 # use pointers by default
obj.class.self_pointers = 0 # don't point to self by default
obj.class.uses_mutators = 0 # don't use mutators by default
obj.class..uses_obj_mut_methods = 1
obj.class.uses_pointers.default = 1
obj.class.self_pointers.default = 0
obj.class.uses_mutators.default = 0
obj.class.uses_obj_mut_methods.default = 1

.macro obj.class, class, class_ppt, dict=point, get=pointer, mut_ns=mut, hook_ns=hook
  .ifb \class_ppt; obj.class \class, is_\class, \dict, \get, \mut_ns, \hook_ns; .exitm; .endif
  # handle default property with class name, if it was blank

  obj.state.altm = alt
  ifalt; obj.state.alt = alt
  ifdef \class\()$; .if ndef; \class\()$ = 0; .endif
  ifdef \class\().is_objClass; .if ndef; \class\().is_objClass = 0; .endif
  obj.class_def = 1; obj.class_ndef = 0
  .if \class\().is_objClass == 0
    obj.class_def = 0; obj.class_ndef = 1
    objClasses$ = objClasses$ + 1
    \class\().is_objClass = objClasses$
    .irp param, .uses_pointers, .self_pointers, .uses_mutators, .uses_obj_mut_methods
      ifdef \class, \param; .if ndef; \class\param = obj.class\param; .endif
      .irp conc, .default; obj.class\param = obj.class\param\conc; .endr
    .endr

    .macro \class\().obj, objs:vararg
      .ifb \objs; \class\().obj $.__anon\@;
      .else;   obj.state.altm = alt
        ifalt; obj.state.alt = alt
        .irp obj, \objs;
          .ifnb obj; obj.__check_if_def \obj, .\class_ppt, \class, \dict; .endif;
        .endr; ifalt.reset obj.state.alt
        alt = obj.state.altm
      .endif
    .endm


    .if \class\().uses_pointers
      .if \class\().uses_mutators
        .macro \class\().meth, obj, va:vararg;
          .ifb \obj; obj.__def_class_methods \class, \va
          .else; \class\().\get \obj;
            \class\().\dict, obj.__def_obj_methods, \class, \mut_ns, \hook_ns, \va; .endif
        .endm; .macro \class\().call_\mut_ns, self=\class\().\get, hook, mode, va:vararg
        \class\().\get \self
        \class\().\dict, mut.call, \hook, \mode, \class, \mut_ns, \hook_ns, \va
        .endm; mut.class \class, \mut_ns, \hook_ns
      .endif # convenient method builders for designs that include mutable hooks


      .macro \class\().\get, obj, sym=\class\().\get
        ifnum \obj; def=nnum; ndef=num
        .if num; \sym = \obj
        # if arg is a number, then use value directly

        .else; ifdef \obj, ., \class_ppt
          .if def; .irp p, .\class_ppt; \sym = \obj\p; .endr
          # if arg is an obj name, then use obj pointer

          .else; ifdef \obj
            .if def; def=0; ndef=1; \sym = \obj
            # if arg is a symbol, then use value memory

            .else; \sym = 0; .endif
            # else, return null to inform caller of invalid argument

          .endif
        .endif # convenient pointer getter

      .endm; .macro \class\().\dict, point=\class\().\get, va:vararg
        obj.vacount \point
        ifalt;
        .altmacro;
        .if obj.vacount > 1; obj.class.dict.__recurse_start \class, \dict, %\point,, \va
        # handle multiple pointers by listing them with a blank terminator using _recurse

        .elseif \point > 0; obj.class.dict.__eval \class, \dict, %\point, \va
        .endif # convenient stack generator


      .endm; .macro \class\().\dict\()q, point=\class\().\get, va:vararg
        obj.vacount \point
        ifalt; .altmacro;
        .if obj.vacount > 1; obj.class.dictq.__recurse_start \class, \dict, %\point,, \va
        .elseif \point > 0; obj.class.dictq.__eval \class, \dict, %\point, \va
        .endif # convenient queue generator


      .endm; .macro \class\().call_method, self=\class\().\get, meth, va:vararg
        \class\().\get \self; \class\().\dict, obj.__call_method, \meth, \va
      .endm; .macro \class\().set_property, self=\class\().\get, ppt, val=\class\().property
        \class\().\get \self; \class\().\dict, obj.__set_property, \ppt, \val
      .endm; .macro \class\().get_property, self=\class\().\get, ppt, sym=\class\().property
        \class\().\get \self; \class\().\dict, obj.__get_property, \ppt, \sym
        # general purpose object handlers

      .endm
    .endif
  .endif
  ifalt.reset obj.state.alt
  alt = obj.state.altm


# --- static methods:

.endm; .macro obj.vacount, va:vararg; obj.vacount=0
  .irp vacount, \va; obj.vacount=obj.vacount+1; .endr

.endm; .macro obj.hidden_constructor, obj, constr, va
  hidden "_", ", \obj, \va", \constr



# --- hidden layer:

.endm; .macro obj.__call_method, a, b, va:vararg; \a\b \va
.endm; .macro obj.__set_property, a, b, c; \a\b = \c
.endm; .macro obj.__get_property, a, b, c; \c = \a\b
.endm; .macro obj.__check_if_def, obj, ppt, class, dict;
  ifdef \obj\ppt
  obj.def = def
  obj.ndef = ndef
  .if obj.ndef
    .if \class\().uses_mutators; \class\().mut \obj; .endif
    \class\()$ = \class\()$ + 1
    \obj\ppt = \class\()$
    .altmacro
    .irp class_ev, %\class\()$;
      .noaltmacro
      .if \class\().uses_pointers
        .macro $.__\class\().\dict\()$\class_ev, m, va:vararg
          .ifb \va; \m \obj; .else; \m \obj, \va; .endif; .endm
        .macro $.__\class\().\dict\()q$\class_ev, m, va:vararg
          .ifb \va; \m \obj; .else; \m \va, \obj; .endif; .endm
      .endif
      .if \class\().self_pointers; \obj = \class_ev; .endif
      obj.point = \class_ev
      .altmacro
    .endr
  .endif

.endm; .macro obj.__def_obj_methods, obj, class, mut_ns, hook_ns, varg:vararg
  .irp m, \varg; .ifnb \m; \class\().purge_hook \obj, \m; .macro \obj\().\m, va:vararg;
  mut.call \obj, \m, default, \class, \mut_ns, \hook_ns, \va; .endm; .endif; .endr

.endm; .macro obj.__def_class_methods, class, varg:vararg
  .irp m, \varg; .ifnb \m; .macro \class\().\m, obj, va:vararg
  \class\().call_mut \obj, \m, default, \va; .endm; .endif; .endr


.endm; .macro obj.class.dict.__recurse_start, class, dict, point, pointcheck, va:vararg
  # --- set up initial recursive step
  $.__\class\().\dict\()$\point obj.class.dict.__recurse, \class, \dict, <>, <>, %\pointcheck, \va
.endm; .macro obj.class.dict.__recurse, obj, class, dict, comma, stack, point, pointcheck, va:vararg
  .ifnb \pointcheck # --- while pointers remain unevaluated...
    $.__\class\().\dict\()$\point /*
    */ obj.class.dict.__recurse,  \class, \dict, <,>, <\stack\comma \obj>, %\pointcheck, \va
    # blank terminator is recognized when \pointcheck is blank

  .else # --- after consuming all pointers...
    obj.class.dict.__recurse_peak \class, \dict, <\stack\comma \obj>, \point, \va
  .endif

.endm; .macro obj.class.dict.__recurse_peak, class, dict, stack, point, m, va:vararg
  ifalt.reset
  .ifb \va
    .if alt; $.__\class\().\dict\()$\point <\m \stack>
    .else;   $.__\class\().\dict\()$\point "\m \stack"; .endif
  .else;
    .if alt; $.__\class\().\dict\()$\point <\m \stack,>, \va
    .else;   $.__\class\().\dict\()$\point "\m \stack,", \va; .endif
  .endif
.endm; .macro obj.class.dict.__eval, class, dict, point, va:vararg
  ifalt.reset; $.__\class\().\dict\()$\point \va

.endm;.macro obj.class.dictq.__recurse_start, class, dict, point, pointcheck, va:vararg
  $.__\class\().\dict\()$\point obj.class.dictq.__recurse, \class, \dict, <>, <>, %\pointcheck, \va
.endm;.macro obj.class.dictq.__recurse, obj, class, dict, comma, stack, point, pointcheck, va:vararg
  .ifnb \pointcheck
    $.__\class\().\dict\()$\point /*
    */ obj.class.dictq.__recurse, \class, \dict, <,>, <\stack\comma \obj>, %\pointcheck, \va
  .else;obj.class.dictq.__recurse_peak \class, \dict, <\stack\comma \obj>, \point, \va;.endif
.endm; .macro obj.class.dictq.__recurse_peak, class, dict, stack, point, m, va:vararg
  ifalt.reset; .ifb \va
    .if alt; $.__\class\().\dict\()q$\point <\m>, \stack
    .else;   $.__\class\().\dict\()q$\point "\m", \stack; .endif
  .else;
    .if alt; $.__\class\().\dict\()q$\point <\m>, \va, \stack
    .else;   $.__\class\().\dict\()q$\point "\m", \va, \stack; .endif
  .endif
.endm; .macro obj.class.dictq.__eval, class, dict, point, va:vararg
  ifalt.reset; $.__\class\().\dict\()q$\point \va

.endm
.endif
