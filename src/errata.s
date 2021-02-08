# --- Errata Objects
#>toc sidx
# - generate constants that can be referenced before they are defined
#   - requires that the errata doesn't need to be immediately evaluated after being emitted
# - useful for making cumulative results of an arbitrary number of operations, like block contexts

# --- Updates:
# version 0.0.1
# - added to punkpc module library

# --- Constructor Method ---
# --- errata.new  self, ...
# Creates a new errata object with name given by 'self'
# - multiple objects can be defined at once with '...' varargs



  # --- Object Properties ---

  # --- .i - index of current tuple, in errata array memory



  # --- Object Methods ---

  # --- .ref  sym, ...
  # Reference an errata tuple's memory at the current the current index with a symbol assignment
  # Each additional symbol name provided in '...' will reference the next element in a tuple
  # - 'sym' is the name of a symbol that receives the reference assignment
  #   - each reference may be to undefined memory, so long as it become defined before assembly end

  # '.ref' and can accept numbers in place of arguments, to change the '.i' property
  # - if wrapped in [] brackets or () parentheses, any symbol can be interpreted like a number


  # --- .solve  val, ...
  # Solve for all previous references of tuple indices at the current index
  # Each additional value provided in '...' will provide a result for the next element in a tuple
  # - 'val' must be an absolute expression, meaning that it has to be immediately evaluable
  #   - all previous references to undefined memory will recieve the first solve -- like a constant
  #     - this only works if the values being solved for have not yet been defined




# --- Class Methods ---

# --- errata.ref     obj, sym, ...
# --- errata.solve   obj, val, ...
# class-level methods for invoking object methods, optionally via pointer



# --- errata.point         obj, macro, ...
# --- errata.pointq        obj, macro, ...
# --- errata.pointer       obj, sym
# --- errata.call_mut      obj, hook, mode, ...
# --- errata.get_property  obj, ppt, symbol
# --- errata.set_property  obj, ppt, value
# 'obj' pointer methods, for handling both objects and pointers to objects in the same fashion



# --- errata.hook       obj,       hook
# --- errata.mut        obj, mut,  hook
# --- errata.mode       obj, mode, hook
# --- errata.call_hook  obj, hook, mode, ...
# --- errata.purge_hook obj, hook, ...
# 'mut' class-level methods, for handling mutable behaviors
# - they do not accept pointers, but can be handlers for the 'errata.point' method



# --- Errata Modes:

  # Object Method Overrides:
  #     hook        mode
  # --- ref,        default
  # --- solve,      default
  # --- ref_iter,   default
  # --- solve_iter, default
  # Set these to a custom mode/mutator to override default behaviors

  # Custom Modes:
  # --- solve_iter, stack
  # - causes solving a piece of errata to push the index by +1



# --- Errata Hooks:
  #     hook        args
  # --- ref         self, arg, ...
  # --- solve       self, arg, ...
  # --- ref_iter    self, arg, ...
  # --- solve_iter  self, arg, ...
  # Override these with custom mutators

.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module errata, 1
.if module.included == 0

  punkpc obj, sidx, if
  errata.uses_mutators = 1
  errata.uses_pointers = 1
  errata.self_pointers = 1
  errata.uses_obj_mut_methods = 0
  obj.class errata
  .macro errata.new, self, va:vararg
    .ifnb \self
      errata.obj \self
      .if obj.ndef
        errata.meth \self, ref, solve
        errata.purge_hook \self, ref_iter, solve_iter
        \self\().i = 0
        \self\().__val = 0
      .endif
      errata.new \va
    .endif
  .endm; .macro errata.mut.ref.default, va:vararg;  errata.__loop ref_iter, \va
  .endm; .macro errata.mut.solve.default, va:vararg; errata.__loop solve_iter, \va
  .endm; .macro errata.mut.ref_iter.default, self, arg, va:vararg
    ifnum \arg
    .if num; errata.__i = errata.__i - 1; \self\().i = \arg
    .else; sidx.noalt "<\arg = \self>", \self\().i + errata.__i; .endif
  .endm; .macro errata.mut.solve_iter.default, self, arg, va:vararg
    ifnum_ascii \arg
    .if num == '[; errata.__i = errata.__i - 1; \self\().i = \arg
    .else; \self\().__val = \arg
      sidx.noalt "<\self>", \self\().i + errata.__i, "< = \self\().__val>"
    .endif
  .endm; .macro errata.mut.solve_iter.stack, self, va:vararg
    errata.mut.solve_iter.default \self, \va
    .if num != '[
      errata.__i = errata.__i - 1
      \self\().i = \self\().i + 1
    .endif
  .endm; errata.meth, ref, solve
  # methods use pointers to default mutator modes

  .macro errata.__loop, meth, self, va:vararg
    errata.__i = 0; errata.__altm = alt
    ifalt; errata.__alt = alt; .noaltmacro
    .irp arg, \va;
      .ifnb \arg; errata.call_mut \self, \meth, default, \arg; .endif;
      errata.__i = errata.__i + 1
    .endr; ifalt.reset errata.__alt; alt = errata.__altm
    # call method once per non-blank arg; incr 'i' for each arg (blank or not)

  .endm

.endif
