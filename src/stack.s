# --- Stack Objects
#>toc sidx
# - a scalar stack object class, powered by `sidx`
# - useful for making scalar variables that can be pushed, popped, dequeued
#   - corresponding symbol memory can be accessed randomly, if referenced directly
# - can be easily fashioned into arrays, structs, or pointer tables
# - can be easily extended to create more specific features that require scalar memory

# --- Updates:
# version 0.2.2
# - moved bulk of new '.rept' guts over to lower level 'sidx' module
#   - stacks now use sidx to power their own '.rept' class methods
# version 0.2.1
# - added '.rept' and '.rept_range' class level methods
#   - can be used iterate through a stack range without modifying a stack's index counter(s)
# - added 'skip_blank' mutator mode for '.push' hook
# - added 'relative' mutator mode for '.s' hook

# --- version 0.2.0
# - renamed 'stacks' to 'stack', for module name coherency
# - split many 'stack' features into extensions in the form of the new 'list' module
#   - 'stack' objects are now dramatically simplified, and scale less expensively than lists
# - implemented obj module, to make stack pointers (and multi-dimensional stacks)
# - implemented changes to mutator hooks, removing 'self' arguments from hook calls
# - replaced static methods with methods that support pointers
# - replaced object methods with hooks that can be overridden with mutations
# - implemented new mutator hook method for lighter objects (fewer macros in unmutated objects)

# --- version 0.1.0
# - implemented mutator class to handle stack modes
# - added .get and .set methods, to implement new sidx features
# - added .i property, for using .get and .set independently from stack/queue indices
# - added .iter method, for popping from .i by invoking the mutable .i index method
# - added mutable nops, for plugging in behavior for push, iter, i, get, and set
# - removed planned-but-unwritten '.purge' object method -- may re-implement later
# - moved object method guts into static methods, for lighter-weight objects
# - implemented ifalt, to handle case of altmacro usage automatically
# - lots of examples
# version 0.0.2
# - added altmacro methods '.pusha' '.popa' and '.deqa'
# version 0.0.1
# - added to punkpc module library

# --- Class Properties

# --- stack.fill - default fill value for blank push streams and null init values
# --- stack.size - default number of null elements to start in stack
# --- stack.sss  - default maximum index
# --- stack$     - stack ID counter



# --- Class Methods ---

# --- stack.fill   stack, start, size, fill
# Fill a contiguous area in a stack, in altmacro mode
#  stack : the stack to fill
#  start : the index to begin fill at
#   size : the number of elements to fill
#   fill : the value to fill with

# --- stack.point  pointer, handler
# Handle a stack object with the macro or directive, 'handler'
# - pointer is converted into an object name for 'handler' to handle
# - can be used to reference stacks remotely with saved pointer values
#   - saved values can be stacked in other stacks to make multi-dimensional stacks

# --- stack.push  obj, ...
# --- stack.pop   obj, ...
# --- stack.deq   obj, ...
# --- stack.iter  obj, ...
# class-level methods for handling object-level args




# --- Stack Objects ---

# --- stack  name, ...
# Stack objects create index memory variables and stack I/O methods for a given namespace
# - if multiple names are given, then multiple stacks are created
# - you may modify stack.fill or stack.size to change the initial state of each stack
#   - these arguments will return back to their defaults for the next call to the constructor

# --- Object Properties:
  # --- (self)    - scalar property buffers values for pushing and popping, as I/O interface
  # --- .is_stack  - unique non-0 stack ID creates a pointer usable with 'stack.point' method
  # --- .sss      - stack index -- the maximum index of this stack object
  # --- .ss       - stack index -- the highest index of this stack object (that has been written)
  # --- .s        - stack index -- the current index of this stack object
  # --- .pop      - outpipe memory of last popped value (from self buffer)
  # --- .deq      - outpipe memory of last dequeued value (from memory)
  # --- .q        - queue index -- the current bottom of pipe window
  # --- .qq       - queue index -- the lowest index of this pipe window
  # --- .qqq      - queue index -- the minimum index of this stack object



# --- Stack Object Methods:

  # --- .push   val, ...
  # Push value(s) to stack memory
  # - if no value is given, self is pushed instead of an input value
  #   - when self is pushed, the buffer will be assigned a fill value, which is normally 0
  # - multiple values can be stacked in the order given
  # - value of self is cleared with self.fill value

  # --- .pop    sym, ...
  # Copy self to pop stream output, and update self with top memorized push value
  # - if no symbol is given, self.pop is used for output stream
  # - multiple symbols will cause popped values to be assigned to each, in a sequence

  # --- .popm   sym, ...
  # A variation of '.pop' that uses top of memory instead of self buffer
  # - if no symbols are provided, then it will be the same as the normal '.pop' method

  # --- .deq    sym, ...
  # Copy bottom memorized push value to deq stream output, ignoring self buffer
  # - if no symbol is given, self.deq is used for output stream
  # - multiple symbols will cause dequeued values to be assigned to each, in a sequenc

  # --- .reset fill, start, size
  # Reset the queue position to lowest memory, and the stack position according to given size
  # - if a fill value is given, then the range will be filled, updating boundaries accordingly
  # - at end of reset, minimum and maximum boundaries are checked, and idices are adjusted


  # --- .mut   macro, hook_name, ...
  # Mutate the object's hook 'hook_name' to use behavior of 'macro' instead of its current behavior
  # - see below for stack of mutable behaviors

  # --- .mode  hook_name, mode_name, ...
  # low level method for interacting with real macro names for mode behaviors

  # --- .hook  hook_name, ...
  # Automatically initializes hooks by mapping them to the default 'stack.mut.\hook_name' macro



# --- Stack Modes:
# Use '.mode' to set these keyword combinations '\hook, \mode' manually
# - each of the following is a \hook, \mode  keyword combination


  # Object Method Overrides:
  #     hook   mode
  # --- reset, default
  # --- push,  default
  # --- pop,   default
  # --- popm,  default
  # --- deq,   default
  # Set these to a custom mode/mutator to override default behaviors
  # - use 'stack.mut.(hook).default' to call these directly for extending the default behavior


  # Out-Of-Bounds (oob) Exception Modes:
  # - behaviors for handling navigations that move out of index limitations
  # --- oob_push,  incr  -- push default
  # 'incr' mode keyword, for handling writing OOB
  # - this just increments the stack size to accomodate a push that would be out of write bounds
  # - replacing this with 'nop' will disalow pushing the frame beyond the '.ss' index

  # --- oob_push,  step
  # 'step' mode keyword allows for iterating in strides determined by 'step' size

  # --- oob_push,  nop
  # --- oob_pop,   nop
  # --- oob_deq,   nop
  # 'nop' mode keywords, for no action on both read and write OOB

  # --- oob_push,  rot
  # --- oob_pop,   rot
  # --- oob_deq,   rot
  # 'rot' mode keyword, for rotating back to opposite side of memory range

  # --- oob_pop,   null  -- pop default
  # --- oob_deq,   null  -- deq default
  # 'null' will freeze the stack index, and produce blank 'fill' values in pop stream

  # --- oob_pop,   cap
  # --- oob_deq,   cap
  # 'cap' mode keywords, for undoing the iteration of a count that reads OOB
  # - this will subtract index step that was just made so that the final element is re-read



# --- Stack Hooks:
# Use '.mut' with these keywords to assign new macros in place of default hooks
# - Mutators will be called like callbacks, with the following provided arguments

  # --- popm      self, ...
  # --- reset     self, ...
  # --- push      self, ...
  # --- pop       self, ...
  # --- deq       self, ...
  # Override these to completely change the corresponding methods

  # --- oob_push  self, sym, ...
  # --- oob_pop   self, sym, ...
  # --- oob_deq   self, sym, ...
  # Override these to implement custom exceptions/navigation methods

.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module stack, 0x202
.if module.included == 0; punkpc sidx, if, obj

# Static Properties:
stack.fill = 0          # default fill value for blank push streams and null init values
stack.size = 0          # default number of null elements to start in stack
stack.sss = 1<<31-1     # default maximum index
stack$ = 0              # stack ID counter
stack.idx = 0
stack.oob = 0
stack.uses_mutators = 1
obj.class stack
mut.class stack
# This allows us to create and use mutable behaviors for the class 'stack'

# --- Constructors:
.macro stack, self, varg:vararg
  stack.obj \self
  .if obj.ndef
    \self\().s = stack.size
    ifdef \self; .if ndef; \self = stack.fill; .endif
    .irp ppt, s, ss, pop, q, qq; \self\().\ppt=0; .endr
    \self\().init_size = stack.size
    \self\().fill = stack.fill
    \self\()$0 = stack.fill
    \self\().sss = stack.sss
    .if \self\().init_size > 0
      .altmacro
      stack.fill \self, 0, \self\().size, \self\().fill
      .noaltmacro
    .endif

    .macro \self\().reset, fill, start=\self\().qq, size=\self\().init_size, va:vararg
      mut.call \self, reset, default, stack,,, \fill, \start, \size, \va

    .endm; .macro \self\().push, va:vararg=\self
      mut.call \self, push, default, stack,,, \va

    .endm; .macro \self\().pop, va:vararg=\self\().pop
      mut.call \self, pop, default, stack,,, \va

    .endm; .macro \self\().popm, va:vararg
      mut.call \self, popm, default, stack,,, \va

    .endm; .macro \self\().deq, va:vararg=\self\().deq
      mut.call \self, deq, default, stack,,, \va

    .endm; stack.mut \self
  .else; mut.call \self, reset, default, stack; .endif
    stack.purge_hook \self,fill,s,ss,q,new,reset,push,pop,popm,deq,oob_push,oob_pop,oob_deq
    # purged hooks initialize symbols for hook objects, but not the hook methods
    # - defaults will be used, since the hooks are not instantiated
    # - if a hook mode is changed, then a hook method will be instantiated

  .ifnb \varg; stack \varg; .else; .irp ppt,fill,size,;stack.\ppt = 0; .endr; .endif
  # reset constructor argument properties after constructing all varargs

.endm;


# --- static methods:

stack.meth, fill, s, ss, q, new, reset, push, pop, popm, deq
  # these class-level methods can handle object pointers without invoking methods

.macro stack.rept, self, va:vararg
  sidx.memalt = alt; ifalt
  sidx.alt = alt
  stack.pointer \self
  stack.point, stack.__rept, +1, , , \va
.endm; .macro stack.rept_range, self, va:vararg
  sidx.memalt = alt; ifalt
  sidx.alt = alt
  stack.pointer \self
  stack.point, stack.__rept, +1, \va
.endm; .macro stack.__rept, self, step, start, end, macro, va:vararg
  .ifb \start; stack.__rept \self, +1, \self\().q, \self\().s-1, "\macro", \va
  .else; sidx.__rept \self, \step, \start, \end, "\macro", \va; .endif
.endm; .macro stack.__check_first_blank, arg, va:vararg
  .ifb \arg; stack.__check_blank = 1; .else; stack.__check_blank = 0; .endif
  # syntax helper


.endm; .macro stack.__fill, self, start, size, fill; LOCAL i, idx, f#
  .ifb \start; idx = \self\().qq; .else; idx = \start; .endif
  .ifb \size; i = \self\().init_size; .else; i = \size; .endif
  .ifb \fill; f = \self\().fill; .else; i = \fill; .endif
  .if \self\().sss < (idx+i); i = \self\().sss - idx; .endif
  .if (idx <= \self\().ss) && (\self\().ss < (idx+i)); \self\().ss = idx+i; .endif
  .if i > 0; .rept i;sidx.ema \self, %idx, <=f>;idx=idx+1;.endr; .endif
  # used to fill multiple elements at once



# --- Static mutable behaviors
.endm; .macro stack.mut.fill.default, va:vararg; .altmacro; stack.__fill \va
.endm; .macro stack.mut.s.default, self, idx, va:vararg
  .ifb \idx; stack.mut.s.default \self, \self\().ss;
  .else; \self\().s=\idx; .if \idx > \self\().ss;\self\().s=\self\().ss;.endif; .endif
.endm; .macro stack.mut.ss.default, self, idx, va:vararg;
  .ifb \idx; stack.mut.ss.default \self, \self\().ss
  .else; \self\().s=\idx;  .if \idx > \self\().sss; \self\().s = \self\().sss; .endif
    .if \idx > \self\().ss;\self\().ss=\self\().s;.endif; .endif
.endm; .macro stack.mut.q.default, self, idx, va:vararg;
  .ifb \idx; stack.mut.q.default \self, \self\().qq;
  .else; \self\().q=\idx; .if \idx < \self\().qq;\self\().q=\self\().qq;.endif; .endif
    # s and q index methods limit the stack and queue to existing indices

.endm; .macro stack.mut.new.default, self, size=1, fill, va:vararg
  .ifb \fill; stack.mut.new.default \self, \size, \self\().fill
  .else; stack.fill \self, \self\().ss+1, \size, \fill; .endif
# new pushes a fill value to n elements above stack

.endm; .macro stack.mut.popm.default, self, va:vararg;
  stack.pop \self;.ifnb \va; stack.pop \self, \va;.endif
# popm is a version of pop that discards the current buffer value and works only from stack memory

.endm; .macro stack.mut.reset.default, self, fill, start, size
  .ifb \start; stack.mut.reset.default \self, \fill, \self\().qq, \size; .exitm; .endif
  .ifb \size; stack.mut.reset.default \self, \fill, \start, \self\().init_size; .exitm; .endif
  \self\().q = \start; \self\().s = \self\().q + \size;
  .ifnb \fill; stack.fill \self, \self\().q, \size, \fill; .endif
  .if \self\().q < \self\().qq; \self\().q = \self\().qq; .endif
  .if \self\().s > \self\().ss; \self\().s = \self\().ss; .endif
  # reset stack and queue index to default positions, and optionally fill the range

.endm; .macro stack.mut.push.default, self, va:vararg;
  .ifb \va; stack.mut.push.default, \self, \self
  .else; ifalt; stack.memalt = alt; .altmacro
    .irp val,\va;
      .ifnb \val
        .if \self\().s < \self\().sss
          .if \self\().s >= \self\().ss; stack.oob=1;
            mut.call \self, oob_push, incr, stack,,, \val; .endif
          .if stack.oob==0;
            sidx.ema \self, %\self\().s, <=\val>
            \self\().s = \self\().s + 1;  \self = \self\().fill; .endif;
      .endif; .endif; stack.oob=0
    .endr; ifalt.reset stack.memalt; stack.oob=0; .endif
  # push saves stack buffer value to indexed memory, and clears buffer

.endm; .macro stack.mut.pop.default, self, va:vararg;
  .ifb \va; stack.mut.pop.default \self, \self\().pop
  .else;  ifalt; stack.memalt = alt; .altmacro
    .irp sym,\va
      .ifnb \sym
        .if \self\().s <= \self\().q; stack.oob=1;
            mut.call \self, oob_pop, null, stack,,, \sym; .endif
        .if stack.oob==0; \self\().pop = \self; \sym = \self
          \self\().s = \self\().s - 1; sidx.ema <\self = \self>, %\self\().s; .endif
      .endif; stack.oob=0;
    .endr; ifalt.reset stack.memalt; stack.oob=0; .endif
  # pop works with stack buffer, so both self and self.pop are updated


.endm; .macro stack.mut.deq.default, self, va:vararg;
  .ifb \va; stack.mut.deq.default, \self, \self\().deq
  .else;  stack.memalt = alt; .altmacro
    .irp sym,\va
      .ifnb \sym; stack.oob=0
        .if \self\().q+1 >= \self\().s; stack.oob=1;
          mut.call \self, oob_deq, null, stack,,, \sym; .endif
        .if stack.oob==0; sidx.ema <\self\().deq=\self>, %\self\().q
        \sym = \self\().deq; \self\().q = \self\().q + 1; .endif
      .endif; stack.oob=0
    .endr; ifalt.reset stack.memalt; stack.oob=0; .endif
  # de-queue works independently from stack buffer, so only self.deq is updated




.endm; .macro stack.mut.s.relative, self, idx=1, va:vararg
  stack.mut.s.default \self, \self\().s + \idx, \va
.endm; .macro stack.mut.push.skip_blank, self, va:vararg
  stack.__check_first_blank \va
  .if stack.__check_blank; stack.mut.s.relative \self, \va
  .else; stack.mut.push.default \self, \va; .endif


# --- Default Modes

.endm; .macro stack.mut.oob_pop.default, va:vararg; stack.mut.oob_pop.null \va
.endm; .macro stack.mut.oob_deq.default, va:vararg; stack.mut.oob_deq.null \va
.endm; .macro stack.mut.oob_push.default, va:vararg; stack.mut.oob_push.incr \va
# - these (and the following) create the various 'modes' for I/O methods




# --- NOP - Read/Write
.endm; .macro stack.mut.oob_push.nop, self, va:vararg; stack.oob=0
.endm; .macro stack.mut.oob_pop.nop, self, va:vararg; stack.oob=0
.endm; .macro stack.mut.oob_deq.nop, self, va:vararg; stack.oob=0
# 'nop' mode keywords, for no action on both read and write OOB




# --- ROT - Read/Write
.endm; .macro stack.mut.oob_push.rot, self, sym, va:vararg
  \self\().s = \self\().qq; stack.oob = 0
  .if \self\().q > \self\().s; \self\().q = \self\().s; .endif

.endm; .macro stack.mut.oob_pop.rot, self, sym, va:vararg
  \self\().s = \self\().ss; stack.oob = 0

.endm; .macro stack.mut.oob_deq.rot, self, sym, va:vararg
  sidx.ema <\self\().deq=\self>, %\self\().q; \sym = \self\().deq; \self\().q = \self\().qq
# 'rot' mode keyword, for continuing out-of-bounds by rotating back to opposite side of memory range




# --- INCR - Write-only
.endm; .macro stack.mut.oob_push.incr, self, va:vararg
  \self\().ss = \self\().s + 1; stack.oob = 0
# 'incr' mode keyword, for handling writing OOB
# - this just increments the stack size to accomodate a push that would be out of write bounds
# - replacing this with 'nop' will disalow pushing the frame beyond the '.ss' index

.endm; .macro stack.mut.oob_push.step, self, va:vararg
  \self\().ss = \self\().s + \self\().step
  \self\().s  = \self\().s + \self\().step - 1
  stack.oob = 0
  # 'step' mode keyword allows for iterating in strides determined by 'step' size



# --- NULL - Read-only
.endm; .macro stack.mut.oob_pop.null, self, sym, va:vararg
  \sym = \self; \self = \self\().fill
.endm; .macro stack.mut.oob_deq.null, self, sym, va:vararg
  .if \self\().q == \self\().s; \sym=\self\().fill; \self\().deq = \sym
  .else; sidx.ema <\self\().deq=\self>, %\self\().q; \sym = \self\().deq; \self\().reset,,0; .endif
# 'null' mode keywords, for producing a fill value when reading OOB
# - this will use the .fill property (0 by default) to give you a 'null' instead of a memory value




# --- CAP - Read-only
.endm; .macro stack.mut.oob_pop.cap, self, va:vararg
  \self\().s = \self\().q+1; stack.oob=0
.endm; .macro stack.mut.oob_deq.cap, self, va:vararg
  \self\().q = \self\().s-1; stack.oob=0
# 'cap' mode keywords, for undoing the iteration of a count that reads OOB
# - this will subtract index step that was just made so that the final element is re-read
.endm
.endif
/**/
