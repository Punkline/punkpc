/*## Header:
# --- Errata Objects
# Errata object generator, for assisting in delayed evaluations for symbol constants
# - reference a symbol that keeps a future evaluation before it is defined to create errata
# - solve the symbol to resolve all future references in the errata step of the assembly

##*/
##/* Updates
# version 0.0.1
# - added to punkpc module library
##*/
/*## Attributes:

# --- Class Properties ---


# --- Constructor Method ---

  # --- Object Properties ---

  # --- Object Methods ---

# --- Class Methods ---


## Binary from examples:


##*/
/*## Examples:
.include "punkpc.s"
punkpc errata
# Use the 'punkpc' statement to load this module, or include the module file directly



# --- WHAT IS ERRATA? ---
# The assembler tries do everything in one pass, without backtracking.
# The 'errata' step (at the end) will try to resolve undefined evaluations it encountered earlier


_start:
# This and the labels '_a', '_b', '_c', and '_d' will measure the index of the program counter
# - all labels are relative addresses
# - subtracting a relative addr like '_start' from another one like '_a' creates an absolute value
#   - we can interpret absolute values, but not relative ones
#   - we will make absolute byte offsets for for errata solutions 'a', 'b', 'c', and 'd'


# If a value can't be resolved in the errata step, another attempt is made after the linker step(s)
# Without a linker however, there is no linker step, so errata is the final check for resolving



.long not_defined
# >>> 0
# .long doesn't need to immediately evaluate, so it emits 0 for the linker to resolve later
# - without the linker, this never happens and a silent 0 is produced without error
# - because of this, the symbol 'not_defined' emits 0 even though it isn't defined



_a:
# This is byte offset '4' of the assembled program, so far...


show_errors = 0
.if show_errors

  .if not_defined
    .long 1
  .else
    .long 0
  .endif
  # >>> Error: non-constant expression in ".if" statement
  # - turn on 'show_errors' to see this result

.endif
# .if evaluations need immediate evaluation
# - attempting to use errata in statements that need immediate evaluation will create errors



# Knowing the difference, you may intelligently use errata to delay evaluations for some directives
# - this also works with instructions

_b:
# This would be byte offset '8' if the above if statement didn't break
# Because of this, whenever successfully assembled, this will be '4' just like '_a'




.long defined_later
# >>> 1
# Why would this emit as 1 if we havn't defined it?

# Because of errata:

defined_later = 1
# If a symbol is defined later on in the assembler, the errata step will resolve the evaluation
# - this delay is what causes errors to be made in steps that require immediate resolution
# - simple directives and instructions will not require immediate evaluation




# --- ERRATA OBJECTS ---

errata.new  e
# this creates a new self-pointing errata object, called 'e'
# - we can use it to create errata tuples

e.ref  a, b, c, d
# - this creates 4 unique errata references 'a', 'b', 'c', 'd'
# - these contain no value until indices 0 ... 3 are solved in 'e'
_c:
li r3, a
li r4, b
li r5, c
li r6, d
# these instructions will load immediates with the values that end up in tuple 'e'



_d:
# with labels _start, _a, _b, _c, and _d all defined, we can finally solve the errata:

e.solve  _a-_start, _b-_start, _c-_start, _d-_start
# The tuple in 'e' has been given absolute expressions that solve its errata
# - now the above 'li' instructions have the corresponding values:

# Now that the errata is solved, references to it can be used in immediate expressions:

.if a == 4
  .long 1
.else
  .long 0
.endif
# >>> 1
# The symbol 'a' is evaluable -- unlike in the previous example using the '.align' directive




# --- ERRATA OBJECT INDICES ---
# Each errata object has a scalar index keeping track of its errata indices
# - this index can be changed when using '.ref' or '.solve' with numerical expression arguments

# You can change an index directly by assigning a value to an errata object's '.i' property:

e.i = 3
e.ref size
.long size
# >>> 0x18
# - this is the value we solved as 'd'
# - it is at index [3] of the tuple, so changing '.i' to '3' makes it the first referenced value




# The methods will also accept absolute index values as expression inputs, if given:

e.ref [0], x, y
.long x, y
# >>> 4, 4
# The [] brackets work just like () parentheses, creating an expression out of the middle
# - you may use any literal numerical characters, or +/- operators as well

.long e.i
# >>> 0
# Referencing or solving does not move the index, so it is still at our assigned [0]
# - you may use this to create a sliding 'frame' or 'window' in an array of values or tuples





# --- ERRATA MUTATORS ---
# Mutators can be applied to errata objects from the class level using '.mut', '.mode', or '.hook'

errata.mode  e,  my_mode,  ref
# this mutates the '.ref' method to a custom behavior mode called 'my_mode'
# - mutator hooks can be instantiated like this for undefined macros so long as they are not called
# - calling the hooks without defining them will create errors
#   - you may use '.mut' with a blank mutator name to create no-op placeholder macros for any hook



# We define this behavior by using the following namespace for a new macro:

.macro errata.mut.ref.my_mode, self, arg, va:vararg
# 'errata.mut.' is the mutator namespace
# '.ref.'       is the hook being mutated
# '.my_mode'    is the dictionary keyword used for this behavior, when selecting a mode

  ifnum_ascii \arg
  .if (num == '+) || (num == '-)
    \self\().i = \self\().i + \arg
    errata.mut.ref.default \self, \va
    # if first argument starts with a '+' or a '-', then it adds or subtracts a relative index
    # - the rest of the args are handled by default behavior

  .else;  errata.mut.ref.default \self, \arg, \va
  # else just handle it with the default behavior, only

  .endif
.endm



# This is the custom 'my_mode' behavior we will apply to our object 'e':

e.ref 1
.long e.i
# >>> 1
# This sets the index to 1, because it starts with a number

e.ref +1
.long e.i
# >>> 2
# This adds +1 to the index, because it starts with a '+'
# - this is the custom behavior we mutated 'e' with



# Note: errata objects do not have object-level mode changing methods, only class-level
# - this is to keep the objects as light-weight as possible




# --- ERRATA POINTERS ---
# Errata objects are a type of object that makes a copy of its own pointer in its main property:

.long e
# >>> 1
# - 'e' is the first errata object we made, so its object pointer is 1



# The real pointer value is stored in a property called '.is_errata':

.long e.is_errata
# >>> 1
# - this is checked for when looking to see if this is an object of the 'errata' class



# The main property can therefor be used (by default) to copy the errata, as a reference:

pointer = e
errata.ref pointer, -1, x, y
.long x, y
# >>> 4, 8
# The mutator 'my_mode' is still invoked from the class level, using a pointer
# - in this case, using a '-' in '-1' causes the index to become '-= 1'




##*/

.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module errata, 1
.if module.included == 0

  punkpc obj, sidx, if
  errata=0
  errata$=0
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
        \self\().i = 0
        \self\().__val = 0
      .endif
      errata.new \va
    .endif
  .endm; .macro errata.mut.ref.default, va:vararg;  errata.__loop ref, \va
  .endm; .macro errata.mut.solve.default, va:vararg; errata.__loop solve, \va
  .endm; errata.meth, ref, solve
  # methods use pointers to default mutator modes

  .macro errata.__loop, meth, self, va:vararg
    errata.__i = 0; errata.__altm = alt
    ifalt; errata.__alt = alt; .noaltmacro
    .irp arg, \va;
      .ifnb \arg; errata.__\meth \self, \arg; .endif;
      errata.__i = errata.__i + 1
    .endr; ifalt.reset errata.__alt; alt = errata.__altm
    # call method once per non-blank arg; incr 'i' for each arg (blank or not)
    # - preserves altmacro mode

    .endm; .macro errata.__ref, self, arg
      ifnum \arg
      .if num; errata.__i = errata.__i - 1; \self\().i = \arg
      .else; sidx.noalt "<\arg = \self>", \self\().i + errata.__i; .endif
    .endm; .macro errata.__solve, self, arg
      ifnum \arg
      .if num; errata.__i = errata.__i - 1; \self\().i = \arg
      .else; \self\().__val = \arg
        sidx.noalt "<\self>", \self\().i + errata.__i, "< = \self\().__val>"
      .endif
    .endm

.endif
