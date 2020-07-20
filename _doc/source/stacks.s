/*## Header:
# --- Stacks
# Create objects that can stack values, and pop or de-queue them
# Stack objects use 'self' like a normal symbol that can be treated like a scalar variable
# - this scalar variable interacts with the stack structure using object methods that can be called

##*/
/*## Attributes:
# --- Static Properties ---

# --- stack.fill - default fill value for blank push streams and null init values
# --- stack.size - default number of null elements to start in stack
# --- stack.sss  - default maximum index
# --- stack$     - stack ID counter


# --- Constructor Method ---

# --- stack  name, ...
# Stack objects create index memory variables and stack I/O methods for a given namespace
# - if multiple names are given, then multiple stacks are created
# - you may modify stack.fill or stack.size to change the initial state of each stack
#   - these arguments will return back to their defaults for the next call to the constructor
#   - multiple stacks made with a single call will share the same properties


# --- Object Properties:
  # --- (self)    - scalar property buffers values for pushing and popping, as I/O interface
  # --- .isStack  - unique non-0 stack ID helps keep track of this stack's existence, when inquired
  # --- .sss      - stack index -- the maximum index of this stack object
  # --- .ss       - stack index -- the highest index of this stack object (that has been written)
  # --- .s        - stack index -- the current index of this stack object
  # --- .pop      - outpipe memory of last popped value
  # --- .deq      - outpipe memory of last dequeued value in pipe operation
  # --- .q        - queue index -- the current bottom of pipe window
  # --- .qq       - queue index -- the lowest index of this pipe window
  # --- .qqq      - queue index -- the minimum index of this stack object


# --- Object Methods:

  # --- .push   val, ...
  # Push value(s) to stack memory
  # - if no value is given, self is used
  # - multiple values can be stacked in the order given
  # - value of self is cleared with self.fill value

  # --- .push.mode  mode
  # Change the way .push operates when encountering the edge of push memory
  #  mode: incr : DEFAULT - push memory index so that pushed value can be stored
  #  mode: nop  : do nothing, causing memory boundary to become a limit
  # - nop may be useful for temporarily disabling pushing below the maximum

  # --- .pop    sym, ...
  # Copy self to pop stream output, and update self with top memorized push value
  # - if no symbol is given, self.pop is used
  # - multiple symbols will cause popped values to be assigned to each, in a sequence

  # --- .deq    sym, ...
  # Copy bottom memorized push value to deq stream output, ignoring self buffer
  # - if no symbol is given, self.deq is used
  # - multiple symbols will cause dequeued values to be assigned to each, in a sequenc

  # --- .pop.mode  mode
  # --- .deq.mode  mode
  # Change the way .pop operates when colliding with bottom of queue
  #  mode : null  : DEFAULT - freeze the stack index, and produce .fill values in pop stream
  #  mode : rot   : rotate stack index back to highest memorized stack value
  #  mode : cap   : continuously re-pop the last value in stack memory
  #  mode : nop   : abort the pop operation, freezing index and pop stream entirely

  # --- .s   idx
  # Stack index function
  # - sets index self.s
  # - if no index is given, highest memory index is used
  # - caps in range self.q ... self.ss

  # --- .q   idx
  # Queue index function
  # - sets index self.q
  # - if no index is given, lowest memory index is used
  # - caps in range self.qq ... self.s

  # --- .topget  sym, ...
  # Assign value of current stack index memory to symbol(s)
  # - this ignores the currently buffered value in self
  # - if no symbol is given, self is used for assignment of memory value
  # - if multiple symbols are given, they are all assigned the same value
  # - if memory doesn't exist, then a .fill value is assigned instead

  # --- .topset  val
  # Assign a value to the current stack index memory
  # - if no value is given, the value of self is used
  # - else, this ignores the currently buffered value in self

  # --- .new  size, fill
  # Push stack index memory by size, filling it with given fill value
  # - if no size is given, 1 is used
  # - if no fill is given, self.fill is used

  # --- .reset fill, start, size
  # Reset the queue position to lowest memory, and the stack position according to given size
  # - if a fill value is given, then the range will be filled, updating boundaries accordingly
  # - at end of reset, minimum and maximum boundaries are checked, and idices are adjusted

  # --- .purge ...
  # Destroy the methods for this object
  # - properties remain intact
  # - if ... contains additional method names, they will be purged as well


# --- Object Altmacro Methods:
  # --- .pusha  val, ...
  # --- .popa   sym, ...
  # --- .deqa   sym, ...
  # These object methods may be used within altmacro mode without reverting to noaltmacro mode


# --- Static Methods ---

# --- stack.fill   stack, start, size, fill
# Fill a contiguous area in a stack, in altmacro mode
#  stack : the stack to fill
#  start : the index to begin fill at
#   size : the number of elements to fill
#   fill : the value to fill with

# --- stack.oob  stack, method, behavior
# A macro for plugging callbacks into a method event as a behavior
#    stack : the stack to mutate
#   method : the method to mutate
# behavior : suffix of the static behavior name
# - behavior callback must be called stack.oob.'method'.'behavior'
# - intended to be used through various object '.mode' event methods

##*/
/*## Examples:
.include "./punkpc/stacks.s"

# --- BASICS ---

stack a, b
# create stacks 'a' and 'b'
# these may be used like regular symbols that have methods for interfacing with a stack

a.push 1, 2, 3, 4
# push some values to stack 'a'
# - the value of 'a' is now blank

.long a, a.s
# >>> 0, 4
# buffered 'a' value is blank after pushing, but its stack index shows that it is not empty


# This loop uses the .deq method to pop elements from the bottom of the stack:
.rept a.s  # for each stacked value
  a.deq b  # pipe bottom value to stack 'b' buffer symbol
  .long b
  b.push   # push buffer in stack 'b'
.endr
# >>> 1, 2, 3, 4
# de-queue elements in 'a'
# each element is piped to the 'b' buffer
# each element gets pushed to the 'b' stack
# - using a.s directly for the loop count only works when queue index is 0
#   - to pick up from a partially iterated queue, use (a.s - a.q) instead

.long a.s, b.s
# >>> 0, 4
# stack 'a' is now empty, and stack 'b' is not
# - this is because we've just piped the contents of a -> b


b = 5
# set buffer value in 'b' directly to 5
# - buffer acts like top of the stack when popping, but not when de-queueing

# This loop uses the .pop method to pop elements from the top of the stack:
.rept b.s + 1  # for each stacked value -- including the currently buffered value
  b.pop a      # pipe top value to stack 'a' buffer symbol
  .long a
  a.push       # push buffer in stack 'a'
.endr
# >>> 5, 4, 3, 2, 1
# popping values from a stack presents them in a reversed order
# adding 1 to the loop count and streaming from pop makes the buffer included in the pipe loop

# [ .POP ] <- [ SELF ] .S  (pop comes from self, not memory)
#             [ MEM  ]
#             [ MEM  ]
#             [ MEM  ]
# [ .DEQ ] <- [ MEM  ] .Q  (deq comes from memory, not self)
# - self is included in the pop stream, but not the deq stream
# - to exclude self from the pop stream, stream from the b buffer instead of the pop stream

a = 0
# set buffer value in 'a' to 0
# - buffer will be ignored in the following loop

.rept a.s   # for each stacked value -- excluding the currently buffered value
  a.pop     # pop buffer from stack
  .long a   # buffer is updated with next value
  b.push a  # push next value, discarding popped buffer
.endr
# >>> 1, 2, 3, 4, 5
# not adding 1 to the loop count and streaming directly from the buffer discards the popped value

# --- NULL MODE (DEFAULT) ---

a = 0x1337
a.pop
.long a.pop, a
# outpipe can be reached directly from the .pop property if values are not piped to another stack

a.push 1, 3, 3, 7
.rept a.s <<2
  a.deq b
  .byte b
  b.push
.endr
# >>> 1, 3, 3, 7,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0
# default mode 'null' creates filler values when out of things to pop
# - this is the mode that all new stacks are in when created

a.s
# if given no args, 'self.s' method will reset to highest available memory value

# --- ROT MODE ---

a.deq.mode rot
# mutate stack 'b' de-queue method into a rotation method

.rept a.s <<2
  a.deq b
  .byte b
  b.push
.endr
# >>> 1, 3, 3, 7,  1, 3, 3, 7,  1, 3, 3, 7,  1, 3, 3, 7
# 'rot' mode will rotate through old memory instead of resetting when depleted

a.reset; a.s
# self.reset restores default index values

# --- CAP MODE ---

a.deq.mode cap
# - now the queue will stay at the last available value, instead of null or rotation

.rept a.s <<2
  a.deq b
  .byte b
  b.push
.endr
# >>> 1, 3, 3, 7,  7, 7, 7, 7,  7, 7, 7, 7,  7, 7, 7, 7

##*/



.ifndef stack.included; stack.included=0; .endif; .ifeq stack.included; stack.included = 2
# version 0.0.2
# - added altmacro methods '.pusha' '.popa' and '.deqa'

.include "./punkpc/sidx.s"
.include "./punkpc/ifdef.s"

# Static Properties:
stack.fill = 0          # default fill value for blank push streams and null init values
stack.size = 0          # default number of null elements to start in stack
stack.sss = 1<<31-1     # default maximum index
stack$ = 0              # stack ID counter


.macro stack.fill, stack, start, size, fill; LOCAL i, idx#
  idx = \start; i = \size; .if \stack\().sss < (idx+i); i = \stack\().sss - idx; .endif
  .if (idx <= \stack\().ss) && (\stack\().ss < (idx+i)); \stack\().ss = idx+i; .endif
  .if i > 0; .rept i;sidx.ema \stack, %idx, <=\fill>;idx=idx+1;.endr; .endif

.endm; .macro stack.oob, stack, method, behavior; .purgem \stack\().oob.\method
  .macro \stack\().oob.\method, va:vararg; stack.cb.oob.\method\().\behavior \stack, \va; .endm

.endm; .macro stack, self, varg:vararg
# Construct each given stack object, if name hasn't already been defined
  ifdef \self\().isStack; .if ndef; stack$=stack$+1; \self\().isStack=stack$; \self\().s = size
    ifdef \self; .if ndef; \self = stack.fill; .endif; \self\()$0 = \self\().fill
    .irp ppt,s,ss,pop,q,qq,deq;\self\().\ppt=0;.endr; \self\().fill = stack.fill;
    \self\().init = stack.size; \self\().sss = stack.sss; .if \self\().init > 0; .altmacro;
    stack.fill \self,0,\self\().size,\self\().fill; .noaltmacro; .endif

# s and q index methods limit the stack and queue to existing indices
    .macro \self\().s, idx=\self\().ss; \self\().s=\idx;
      .if \idx > \self\().ss;\self\().s=\self\().ss;.endif
    .endm; .macro \self\().q, idx=\self\().qq; \self\().q=\idx;
      .if \idx < \self\().qq;\self\().q=\self\().qq;.endif

# topget/set create an I/O for interfacing with stack index
    .endm; .macro \self\().topget, sym=\self, va:vararg; sidx.noalt2 /*
      */"<.ifdef \self>",\self\().s,/*
      */"<;\sym=\self>",\self\().s,/*
      */"<;.else;\sym=\self.fill;.endif>"
      .irp v,\va;.ifnb \v; \v=\sym;.endif; .endr
    .endm; .macro \self\().topset, val=\self
      sidx.noalt \self,\self\().s,"< = \val>"

# new pushes a fill value to n elements above stack
    .endm; .macro \self\().new, size=1, fill=\self\().fill
      stack.fill \self, \self\().ss+1, \size, \fill

# reset stack and queue index to default positions, and optionally fill the range
    .endm; .macro \self\().reset, fill, start=\self\().qq, size=\self\().init
      \self\().q = \start; \self\().s = \self\().q + \size;
      .ifnb \fill; stack.fill \self, \self\().q, \size, \fill; .endif
      .if \self\().q < \self\().qq; \self\().q = \self\().qq; .endif
      .if \self\().s > \self\().ss; \self\().s = \self\().ss; .endif

# push saves stack buffer value to indexed memory, and clears buffer
    .endm; .macro \self\().push, va:vararg=\self; .altmacro
      .irp val,\va;
        .if \self\().s < \self\().sss
          .if \self\().s > \self\().ss; \self\().oob=1; \self\().oob.push \val
            .if \self\().oob; .exitm; .endif
          .endif; sidx.ema \self, %\self\().s, <=\val>; \self\().s = \self\().s + 1
          \self = \self\().fill; .endif; .endr; .noaltmacro

# pop works with stack buffer, so both self and self.pop are updated
    .endm; .macro \self\().pop, va:vararg=\self\().pop; .altmacro
      .irp sym,\va
        .if \self\().s <= \self\().q
          \self\().oob=1; \self\().oob.pop \sym
          .if \self\().oob; .exitm; .endif
        .endif; \self\().pop = \self; \sym = \self
          \self\().s = \self\().s - 1
          sidx.ema <\self = \self>, %\self\().s; .endr; .noaltmacro

# de-queue works independently from stack buffer, so only self.deq is updated
    .endm; .macro \self\().deq, va:vararg=\self\().deq; .altmacro
      .irp sym,\va
        .if \self\().q+1 >= \self\().s
          \self\().oob=1; \self\().oob.deq \sym
          .if \self\().oob;.exitm;.endif;
        .endif; sidx.ema <\self\().deq=\self>, %\self\().q
        \sym = \self\().deq; \self\().q = \self\().q + 1
        .endr; .noaltmacro;

# events:
    .endm; .macro \self\().oob.push, va:vararg
    .endm; .macro \self\().push.mode, m; stack.oob \self, push, \m
    .endm; .macro \self\().oob.pop, va:vararg
    .endm; .macro \self\().pop.mode, m; stack.oob \self, pop, \m
    .endm; .macro \self\().oob.deq, va:vararg;
    .endm; .macro \self\().deq.mode, m; stack.oob \self, deq, \m; .endm

# default behaviors for handling out of bounds
    \self\().push.mode incr
    \self\().pop.mode null
    \self\().deq.mode null

  .endif
.ifnb \varg; stack \varg; .else; .irp ppt,fill,size,;stack.\ppt = 0; .endr; .endif; .endm
# reset constructor argument properties after constructing all varargs


# Static callback behaviors, for out of bounds exception handling:
# - these create the various 'modes' for I/O methods

# nops do nothing to handle oob
.macro stack.cb.oob.push.nop,stack, va:vararg;
.endm; .macro stack.cb.oob.pop.nop,stack, va:vararg;
.endm; .macro stack.cb.oob.deq.nop,stack, va:vararg;

# null returns a fill value in place of a real output
.endm; .macro stack.cb.oob.pop.null, stack, sym, va:vararg;
  \sym = \stack; \stack = \stack\().fill

# if deq null, then also reset queue and stack index to beginning of memory
# - this helps encourage recycling memory on queue depletion
.endm; .macro stack.cb.oob.deq.null, stack, sym, va:vararg;
  .if \stack\().q == \stack\().s; \sym=\stack\().fill; \stack\().deq=\sym
  .else; sidx.ema <\stack\().deq=\stack>, %\stack\().q; \sym=\stack\().deq;\stack\().reset,,0; .endif

# incr increments push memory index by 1
.endm; .macro stack.cb.oob.push.incr, stack, va:vararg;
  \stack\().ss=\stack\().s+1;\stack\().oob=0

# cap freezes index in pop streams when out of things to pop
.endm; .macro stack.cb.oob.pop.cap, stack, va:vararg; \stack\().s = \stack\().q+1; \stack\().oob=0
.endm; .macro stack.cb.oob.deq.cap, stack, va:vararg; \stack\().q = \stack\().s-1; \stack\().oob=0

# rot resets the index to lowest/highest in order to rotate memory instead of collapsing or freezing
.endm; .macro stack.cb.oob.pop.rot, stack, va:vararg; \stack\().s = \stack\().ss; \stack\().oob=0
.endm; .macro stack.cb.oob.deq.rot, stack, sym, va:vararg;
  sidx.ema <\stack\().deq=\stack>, %\stack\().q; \sym=\stack\().deq; \stack\().q = \stack\().qq; .endm

.endif
/**/
