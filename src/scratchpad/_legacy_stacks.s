/*## Header:
# --- Stacks
# Create objects that can stack values, and pop or de-queue them
# Stack objects use 'self' like a normal symbol that can be treated like a scalar variable
# - this scalar variable interacts with the stack structure using object methods that can be called

# As of version 0.1.0:
# The symbol memory used by stack and queue methods have random-access get/set methods, as well

##*/
##/* Updates:
# version 0.1.1
# - implemented obj module, to make stack pointers (and multi-dimensional stacks)
# - implemented changes to mutator hooks, removing 'self' arguments from hook calls
# - replaced static methods with methods that support pointers
# - replaced object methods with hooks that can be overridden with mutators

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




##*/
/*## Attributes:
# --- Class Properties

# --- stack.fill - default fill value for blank push streams and null init values
# --- stack.size - default number of null elements to start in stack
# --- stack.sss  - default maximum index
# --- stack$     - stack ID counter



# --- Constructor Method

# --- stack  name, ...
# Stack objects create index memory variables and stack I/O methods for a given namespace
# - if multiple names are given, then multiple stacks are created
# - you may modify stack.fill or stack.size to change the initial state of each stack
#   - these arguments will return back to their defaults for the next call to the constructor
#   - multiple stacks made with a single call will share the same properties



# --- Object Properties:
  # --- (self)    - scalar property buffers values for pushing and popping, as I/O interface
  # --- .isStack  - unique non-0 stack ID creates a pointer usable with 'stack.point' method
  # --- .sss      - stack index -- the maximum index of this stack object
  # --- .ss       - stack index -- the highest index of this stack object (that has been written)
  # --- .s        - stack index -- the current index of this stack object
  # --- .pop      - outpipe memory of last popped value (from self buffer)
  # --- .i        - iter index  -- the current index of this iteration, or last get/set
  # --- .iter     - outpipe memory of last iterated value (from self buffer)
  # --- .step     - step size   -- the number of steps that .i takes on each iteration
  # --- .deq      - outpipe memory of last dequeued value (from memory)
  # --- .q        - queue index -- the current bottom of pipe window
  # --- .qq       - queue index -- the lowest index of this pipe window
  # --- .qqq      - queue index -- the minimum index of this stack object



# --- Object Methods:

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

  # --- .iter   sym, ...
  # Copy self to iter stream output, and update self with nth memorized push value
  # - the sequence will use the .step value to increment/decrement the index in linear steps
  # - if no symbol is given, self.iter is used for output stream
  # - multiple symbols will cause iterated values to be assigned to each, in a sequence

  # --- .deq    sym, ...
  # Copy bottom memorized push value to deq stream output, ignoring self buffer
  # - if no symbol is given, self.deq is used for output stream
  # - multiple symbols will cause dequeued values to be assigned to each, in a sequenc

  # --- .s   idx
  # Stack index method
  # - sets index self.s
  # - if no index is given, highest memory index is used
  # - caps in range self.q ... self.ss

  # --- .ss idx
  # A variation of '.s' that can push '.ss' if out of bounds
  # - caps in rage of self.q ... self.sss

  # --- .i   idx, ...
  # Stack index method
  # - contains a dummy hook, for overriding and adding functionality
  #   - ... is passed to the dummy hook, but not used by the index method directly
  # - without mutation, this is no different than literally assigning .i

  # --- .q   idx
  # Queue index method
  # - sets index self.q
  # - if no index is given, lowest memory index is used
  # - caps in range self.qq ... self.s

  # --- .new  size, fill
  # Push stack index memory by size, filling it with given fill value
  # - if no size is given, 1 is used
  # - if no fill is given, self.fill is used

  # --- .reset fill, start, size
  # Reset the queue position to lowest memory, and the stack position according to given size
  # - if a fill value is given, then the range will be filled, updating boundaries accordingly
  # - at end of reset, minimum and maximum boundaries are checked, and idices are adjusted

  # --- .get     idx, sym, ...
  # Get a stack value by invoking a random-access sidx.get operation
  # NOTE: this method is very fast, but not safe if the given index has not been written to yet!
  # - assigns gotten value to self buffer
  # - if idx is blank, then .i is used
  # - if sym is blank, then self is used
  # - if multiple symbols are provided, values will be gotten in a sequence using .step

  # --- .set     idx, val, ...
  # Set a stack value by invoking a random-access sidx.set operation
  # - if 'val' is blank, then value in self buffer is used
  # - works like .get, syntactically

  # The following are part of the 'mut.s' class module, implemented into stack objs:

  # --- .mut   macro, hook_name, ...
  # Mutate the object's hook 'hook_name' to use behavior of 'macro' instead of its current behavior
  # - see below for list of mutable behaviors

  # --- .mode  hook_name, mode_name, ...
  # low level method for interacting with real macro names for mode behaviors

  # --- .hook  hook_name, ...
  # Automatically initializes hooks by mapping them to the default 'stack.mut.\hook_name' macro



  # --- Mutable Hook Names ---
  # --- "i_plugin"     self, ...
  # add functionality to the .i method

  # --- "iter_plugin"  self, ...
  # add functionality to the .iter method

  # --- "get_plugin"   self, ...
  # add funcitonality to the .get method

  # --- "set_plugin"   self, ...
  # add functionality to the .set method

  # --- "push_pre"     self, ...
  # --- "push_post"    self, ...
  # ALTMACRO MODE CONTEXT: add functionality to the .push method


  # These can be overridden by passing a macro name to the .mut method, like so:
  # --- .mut  macro, i_plugin
  # - this plugs 'macro' into the i_plugin hook
  # - only 1 macro can be accepted by a hook at a time

  # they can also be disabled by providing no macro name:
  # --- .mut       , i_plugin
  # - disabled extra functionality for the .i method



  # --- Hook Modes ---
  # The following mode keywords can be used to mutate existing stack method behaviors
  # - use the provided '.mode' methods to invoke the described keyword behaviors
  # - you may alternatively override these hooks with .mut and a callback of your choosing



  #   WRITE OOB: exception behaviors:
  # --- .push.mode  oob_mode
  # Change the way .push behaves when encountering the edge of push memory
  #    keywords :
  #   --- incr  : DEFAULT - push memory index by +1 so that pushed value can be stored
  #   --- step  - like incr, but increments by +.step amount instead of just +1
  #   --- nop   - do nothing, causing memory boundary to become a limit
  # - nop may be useful for temporarily disabling pushing below the maximum



  #   READ OOB: exception behaviors:
  # --- .pop.mode   oob_mode
  # --- .deq.mode   oob_mode
  # --- .iter.mode  oob_mode
  # --- .i.mode     oob_mode, idx_mode
  # Change the way read operations behave when colliding with bottom of queue
  #    keywords :
  #   --- null  : DEFAULT - freeze the stack index, and produce .fill values in pop stream
  #   --- rot   - rotate stack index back to highest memorized stack value
  #   --- cap   - continuously re-pop the last value in stack memory
  #   --- nop   - abort the pop operation, freezing index and pop stream entirely



  #   INDEXING TYPE: exclusive to the '.i' index method:
  # Change the way the input idx is treated for the .i index method
  #    keywords :
  #   --- range : DEFAULT - index is relative to [q], and limited by [q] ... [s]
  #   --- rel   - like range, but input idx is added to current idx to make a relative idx
  #   --- abs   - absolute index (still invokes OOB)



# --- Static Class Methods ---

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

##*/
/*## Examples:
.include "punkpc.s"
punkpc stacks
# Use the 'punkpc' statement to load this module, or include the module file directly



# --- PUSHING VALUES TO SCALAR MEMORY
# Stacks create a 'scalar variable' out of the object name you give the constructor 'stack'

stack a
# 'a' is now tied to a list of indexable symbols, and can write to it like a stack
# - the list will grow as new values are stacked, and is called the stack 'memory'

a = 1
# 'a' is like a normal symbol that you can assign values to, and use later on in expressions

a.push
.long a
# >>> 0
# 'pushing' a value like this will cause the value of 'a' to be memorized
# - this causes a fill value to overwrite the buffer variable, which is '0' by default

a.push 2, 3, 4
# you can bypass the variable entirely by just providing the values you want to stack as args
# - this causes the values 2, 3, and 4 to be stacked on top of the previously pushed value, 1

.long a
# >>> 0
# the buffer is blank still because we have not read from the stack memory that was pushes

##            STACK
# [ VAL ] -> [ NEW ]  - (.push copies a value to top of memory stack)
#            [ MEM ]
#            [ MEM ]  - (old memory from prior pushes)
#              ...

a = 5
# It's called a 'stack' because it keeps the top-most value in the system randomly accessible
# - by writing to 'a', it's as though we're writing to what is pending a write to stack memory

##            STACK
#              a=5    - (pending storage to memory... can be actively read/written to)
#            [  4  ]  - (first memory value is currently in storage)
#            [  3  ]
#            [  2  ]
#            [  1  ]



# --- POPPING OUTPUT VALUES FROM MEMORY
# You can retrieve memory from the stack by popping with the '.pop' object method

a.pop
.long a
.long a.pop
# >>> 4, 5
# 'popping' a value off the stack will copy the value of 'a' over to the .pop property
# 'a' is then updated to copy the previously indexed stack memory value
# - this allows you to use 'a' like a scalar variable that updates with .pushes and .pops
# - OR it allows you to use 'a.pop' to include the currently buffered value in stream

##            STACK
# [.POP ] <-    X
#            [ a=4 ]  - (first memory value is currently in storage)
#            [  3  ]
#            [  2  ]
#            [  1  ]


# In addition to popping from the buffer value 'a' -> 'a.pop', you can use other symbols
# - x, y, z, and q will be used as examples

a.pop x, y
.long x, y, a
# >>> 4, 3, 2
# By providing symbol names to the '.pop' method, you can pop to those symbols instead of '.pop'
# - these are the values that would normally go to the '.pop' property from the current 'a' value

a.popm x, y, z
.long x, y, z
# >>> 1, 0, 0
# You can use the 'a.popm' variant to discard the current 'a' value
# - this lets you work straight from Memory, which may be preferred for assigning symbols

a.pop x, y
.long x, y
# >>> 0, 0
# Popping beyond the index limit will invoke an exception designed to handle it

##           STACK
#              X
#              X
#              X
# [.POP ] <-  a=0    - (popping at bottom of stack triggers OOB exception)

# By default, this is handled by providing a fill value, '0' in this case
# - see the 'modes' and 'mutators' examples for info on other exception handling methods



# --- STACK INDEX
# The stack is just an interface for randomly accessible memory.
# An [s] index is built into stack objects in order to keep track of the top memory symbol

# Popping consumes memory in the stack only by subtracting from [s]
# - the value in memory is not actually destroyed until another value is pushed over it
#   - you may recover popped memory values by adjusting the stack index and popping again

a.s[4]
# The '.s' object method is the 'stack' index method -- we can influence s with it
# - in this case, [4] references the top of our currently stacked values

a.pop
.long a
# >>> 4
# We set the stack [s] index to 4, and popped the corresponding value back from memory!
# - this only works for values you have not overwritten with another push

.long a.s
# >>> 3
# The '.s' property is the property that gets edited by the '.s' method
# - it can be read or written to in order to interface with current stack index
# - it has just popped from 4 down to 3

.long a.ss
# >>> 4
# The '.ss' property is a record of the highest-written index in memory
# - we could have used this in place of explicitly stating [4] before popping

a.s
.long a.s
# >>> 4
# Alternatively, invoking '.s' without any arguments will cause it to default to '.ss'
# - this can be used to automatically reset your stack index to its highest possible value



# --- STACKS AS QUEUE OUTPUTS
# Popping values causes them to be consumed from the stack in a 'First Out' order
# - this essentially causes the order to be reversed when reading memory
#   - this is a desirable trait when using a stack variable to recover a previous memory state
#   - this may not be desirable if you wish to recall your elements in the order they were stacked

# You can instead read from stack memory as though were a 'queue' to pop in a 'Last Out' order

.long a.q
# >>> 0
# A [q] index is built into stack objects just like the [s] index, to make a working memory range
# - by default it's 0 and can't safely go negative

a.deq x, y
.long x, y
# >>> 1, 2
# the '.deq' object method is an alternative to '.pop' that allows you to 'dequeue' elements
# - this returns them in the order they were stacked in, unlike '.pop'

.long a.q
# >>> 2
# As the queue is consumed, [q] will increment and approach the [s] index boundary

a.deq x, y, z
.long a, x, y, z
# >>> 4, 3, 4, 0
# Like the '.pop' method   -- '.deq' will invoke an out-of-bounds exception when hitting [s]
# Unlike the '.pop' method -- '.deq' has no interaction with the buffered 'a' value
# - 'a' is still 4 from our last write to it, with 'a.pop'

.long a.q, a.s
# >>> 0, 0
# If overflowing [q], its default exception will reset [q] and [s] and produce fill values



# --- CREATING I/O PIPES
# With stacks and queues, you can easily make pipes for process buffered information

stack b
# create a second stack object, 'b'
# - this stack will be used to buffer the outputs of an output made from 'a'

a.s
# reset stack index of a to highest written memory

.rept a.s  # for each index in [s]
  a.pop
  b.push a # stack popped 'a' elements into 'b' stack
.endr

a.s
.rept a.s
  a.deq b  # stack dequeued 'a' elements into 'b' stack
  b.push
.endr
# 'b' essentially creates a palindrome of 'a'

.rept b.s
  b.deq
  .long b.deq
.endr
# >>> 4, 3, 2, 1, 1, 2, 3, 4
# The contents of 'b' are separate from 'a', but were produced by piping 'a' over to 'b'

# When designing pipes, you can use 'a', 'a.pop', and 'a.deq' as outpipes

##             STACK
# [ .POP ] <- [ SELF ] <- .s  - (.pop comes from self bufffer, not memory)
# [ .POP ] <- [ MEM  ]        - (.popm comes from memory, not self)
#             [ MEM  ]
#             [ MEM  ]
# [ .DEQ ] <- [ MEM  ] <- .q  - (.deq comes from memory, not self)
##             QUEUE
# - .s and .q create boundaries for working range
# - .ss and .qq create boundaries for maximum working range
# - .sss creates a boundary for maximum pushable range

# Since pushing causes the self buffer 'a' to become overwritten with a fill value,
#   it's also possible to use the '.fill' property as an inpipe for working with '.push' methods.



# --- RANDOM ACCESS I/O
# Since stacks are based on the 'sidx' punkpc library, they are technically dictionaries
# - the stack interface is just an implementation of this dictionary

# You may directly access stack memory by using the indexed symbol names made for memory values
# These are the name of the stack object plus a '$n' suffix, where n is a decimal number

.long a$0, a$1, a$2, a$3
# >>> 1, 2, 3, 4
# This is fast and efficient, if you know the exact index of what you're trying to copy

# Another way to do this is to use the '.get' or '.set' object methods

a.get[2]
.long a
# >>> 3
# This is almost exactly like using the $n, but also modifies a special [i] index

.long a.i
# >>> 2
# [i] is now at the index that we used for the last '.get' operation

a.get[a.q]
.long a, a.i
# >>> 1, 0
# [i] is now == [q]

a.get[0], x, y, z, q
.long x, y, z, q
# >>> 1, 2, 3, 4
# You can give symbol names as args to store copies from .get
# - this is a good way to access tuple memory, in strides

a.set[4], 5, 6, 7, 8
a.get[4], x, y, z, q
.long x, y, z, q
# >>> 5, 6, 7, 8
# You may also set memory in this manner, ignoring the stack boundary

a.s[8]
.long a.s
# >>> 4
# Setting memory like this does not update the stack index
# - the '.s' method will not push beyond its highest memory

a.ss[8]
.long a.s
# >>> 8
# The '.ss' method can be used to force a stack index to push the highest memory index
# - if not careful, this may lead to gaps in your stack that are not valid for reading
#   - any index that has been written to at least once is safe to read

a.i[0]
# By default, the '.i' index method takes an offset between [q]...[s]

a.get
.long a
# >>> 1
# The 'a' buffer can be used to reference returned get values when no args are given

a.i[-1]
a.get
.long a
# >>> 8
# By default, the '.i' index method rotates to opposite end when out of bounds

a.i[a.s]
a.get
.long a
# >>> 1
# The stack index is considered exclusive in the [i] range, so it will rotate back to [q]

a.q[1]
a.i[0]
a.get
.long a
# >>> 2
# Raising [q] will raise the base index applied to [i] inputs



# --- STACKS AS ITERATORS
# Stacks can be used like iterators with the [i] index, and the '.iter' output pipe

a.q[0]
a.get[0]
# the buffer 'a' will be used in the iter process, like when popping

a.step = 1
# unlike popping, the [i] index uses a custom step value that can be positive or negative
# - this allows you to create an outpipe stream that uses 'a' and doesn't change the stack index

a.iter
.long a.iter
# >>> 1
# The '.iter' property will copy the current value from buffer 'a'

.long a
# >>> 2
# ... and the buffer 'a' updates with the next index determined by '.step'

a.step = 2
a.iter
.long a
# >>> 4
# - note that we skipped over '3'

a.step = -1
a.iter
.long a
# >>> 3
# - we went backwards this time because the '.step' property is negative



# --- STACK MODES
# Stack methods use mutable hooks that can be changed with the '.mode' object methods
# The most common is a hook used to handle various 'out of bounds' exception cases

a.reset
a.push 1, 3, 3, 7
# reset stack memory and push some new values

.rept a.s<<1 # for twice as many pushed numbers in memory...
  a.deq      # ... attempt to pop memory
  .byte a.deq
.endr
# >> 1, 3, 3, 7,   0, 0, 0, 0
# The default behavior when popping out of bounds is to generate a 'null' fill value
# - by default, '.fill' = 0

a.deq.mode rot
# By setting 'a.deq.mode' to a new keyword, we can change this OOB behavior

a.q
.rept a.s<<1
  a.deq
  .byte a.deq
.endr
# >>> 1, 3, 3, 7,   1, 3, 3, 7
# dequeueing in 'rot' mode causes overflows to be handled by resetting [q], repeating itself

a.deq.mode cap
a.q  # reset [q] = [qq]
.rept a.s<<1
  a.deq
  .byte a.deq
.endr
# >>> 1, 3, 3, 7,   7, 7, 7, 7
# dequeueing in 'cap' mode causes overflows to freeze at the final available value

a.deq.mode nop
a.q
.rept a.s<<1
  a.deq
  .byte a.deq
.endr
# >>> 1, 3, 3, 7,  5, 6, 7, 8
# dequeuing in 'nop' mode causes overflows to try reading regardless of boundary error
# - nothing is done to stop the error, resulting in our old memory leaking through
# - if the old memory didn't exist, then this would just cause an error

a.q
a.s[4]
a.step = 1
a.get[0]
.rept a.s<<1
  a.iter
  .byte a.iter
.endr
# >>> 1, 3, 3, 7,  1, 3, 3, 7
# iterating uses 'rot' by default, and will not move the [q] index
# - this allows [q] and [s] to be used to specify the bounds of the rotating index

a.q[3]
a.s[6]
a.i[0]
a.get
.long a
# >>> 7
# [q] sets the base address of [i] inputs by default, but we can change this with i.mode

a.i.mode nop, abs
a.i
a.get
.long a
# >>> 1
# with no arguments, .i uses [0]
# in 'nop' mode, i will basically ignore OOB cases
# in 'abs' mode, i will not be relative to [q], and will use the input idx directly
# - this makes it behave more like [q] or [q]



# --- STACK MUTATORS
# All of the above modes use 'hooks' inside of the object methods in order to function
# In addition to these modes, some blank hooks are provided to make the [i] interface extendable

# To make a plugin injection for any instantiated stack object, first define a macro:

stack RGBA           # example RGBA color stack
RGBA.alpha = 0xFF    # a pre-determined alpha channel value is used when pushing colors
# This is an example of a stack object we can mutate...

.macro myMutator, self, rgb;
  r = (\rgb >> 16) & 0xFF
  g = (\rgb >> 8) & 0xFF
  b = \rgb & 0xFF
  a = \self\().alpha & 0xFF

  \self\().set[\self\().s-1], r, g, b, a  # set 4 values instead of 1
  \self\().ss[\self\().s+3]               # manually push stack index with .ss
  .altmacro # push_post hook is in altmacro context, so we return with .altmacro enabled
.endm
RGBA.mut ".noaltmacro; myMutator", push_post
# This assigns 'myMutator' to the 'push_post' hook in the RGBA stack object
# The '.noaltmacro' statement is included to temporarily subvert the altmacro context
# - now, each RGBA value we push to it will be split into channel bytes, and have alpha overridden


RGBA.push 0x323232, 0x4b645d, 0x6d9889, 0x9fceb3, 0xf5ffd3, 0xffbcaf, 0xf4777f, 0xcf3759, 0x93003a
# buffer 9 RGBA colors from RGB inputs

.long RGBA.s>>2  # number of colors
RGBA.get[0]
.rept RGBA.s
  .byte RGBA     # pipe stream of bytes created from special push mutator
  RGBA.iter
.endr
# >>> 00000009 323232ff
# >>> 4b645dff 6d9889ff
# >>> 9fceb3ff f5ffd3ff
# >>> ffbcafff f4777fff
# >>> cf3759ff 93003aff   # color table


# --- STACK POINTERS
# Stacks use their self property as a buffer, so they can't be referenced just by name as pointers
# However, the '.isStack' property can be copied and used like a pointer with 'stack.point'

stack a, b, c
a = 0x10; b = 0x20; c = 0x30
# set up stacks 'a', 'b', and 'c' to buffer initial values

myPointer = a.isStack
# this saves the pointer ID associated with stack 'a'

stack.point myPointer, .long
# >>> 0x10
# Invoking the pointer with 'stack.point' will show what's currently buffered in the saved pointer
# The argument '.long' is the name of macro or directive that handles the returned object name
# - this lets you reference a scalar through the use of an ID that can be saved in a symbol
#   - the above 'stack.point' statement is just like typing '.long a'


# It's entirely possible to create a 'stack of stacks' this way:

stack stacks
stacks.push a.isStack, b.isStack, c.isStack
# 'stacks' pushes the pointer of 'a', 'b', and 'c' into its memory

stacks.pop
stack.point stacks, .long
# >>> 0x30

stacks.pop
stack.point stacks, .long
# >>> 0x20

stacks.pop
stack.point stacks, .long
# >>> 0x10
# The pointers stored in 'stacks' can be used to invoke the saved stacks 'a', 'b', and 'c'

a.push 0x100, 0x200, 0x300
a.pop
stack.point stacks, .long
# >>> 0x300
# The value of the referenced stack buffers can change and the pointer will still resolve correctly


##*/

.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module stacks, 0x100
.if module.included == 0; punkpc sidx, ifdef, ifalt, mut, obj

# Static Properties:
stack.fill = 0          # default fill value for blank push streams and null init values
stack.size = 0          # default number of null elements to start in stack
stack.sss = 1<<31-1     # default maximum index
stack$ = 0              # stack ID counter
stack.idx = 0
stack.oob = 0
obj.class stack, isStack
mut.class stack
# This allows us to create and use mutable behaviors for the class 'stack'

# --- Constructor:

.macro stack, self, varg:vararg
# Construct each given stack object, if name hasn't already been defined
  stack.obj \self
  .if ndef
    \self\().s = size
    ifdef \self; .if ndef; \self = stack.fill; .endif
    \self\()$0 = \self\().fill
    .irp ppt,s,ss,i,pop,q,qq,deq,iter;\self\().\ppt=0;.endr
    \self\().fill = stack.fill
    \self\().step = 1
    \self\().init = stack.size
    \self\().sss = stack.sss
    .if \self\().init > 0
      .altmacro
      stack.fill \self, 0, \self\().size, \self\().fill
      .noaltmacro
    .endif # initialize properties

# s and q index methods limit the stack and queue to existing indices
    .macro \self\().s, idx=\self\().ss; \self\().s=\idx;
      .if \idx > \self\().ss;\self\().s=\self\().ss;.endif
    .endm; .macro \self\().ss, idx=\self\().ss; \self\().s=\idx;
      .if \idx > \self\().sss; \self\().s = \self\().sss; .endif
      .if \idx > \self\().ss;\self\().ss=\self\().s;.endif
    .endm; .macro \self\().q, idx=\self\().qq; \self\().q=\idx;
      .if \idx < \self\().qq;\self\().q=\self\().qq;.endif

# i is a mutable index method that can be invoked with the '.iter' method
# - the .i index property can is also modified by the '.get' and '.set' methods
    .endm; .macro \self\().i, va:vararg=0; \self\().hook.idx_i \va

# get/set create an I/O for interfacing with iter index, in stack
    .endm; .macro \self\().get, idx=\self\().i, sym=\self, va:vararg
      \self\().i = \idx - 1 # for loop:
      .irp x, \sym, \va
        \self\().i = \self\().i + 1
        .ifnb \x
          sidx.get \self, \self\().i
          \x = sidx
          \self\().hook.get_plugin \x
        .endif; .endr
    .endm; .macro \self\().set, idx=\self\().i, val=\self, va:vararg
      \self\().i = \idx - 1
      .irp x, \val, \va
        \self\().i = \self\().i + 1
        .ifnb \x
          sidx = \x
          sidx.set \self, \self\().i
          \self\().hook.set_plugin \x
        .endif; .endr

# new pushes a fill value to n elements above stack
    .endm; .macro \self\().new, size=1, fill=\self\().fill
      stack.fill \self, \self\().ss+1, \size, \fill

# reset stack and queue index to default positions, and optionally fill the range
    .endm; .macro \self\().reset, fill, start=\self\().qq, size=\self\().init
      stack.reset \self, \fill, \start, \size

# push saves stack buffer value to indexed memory, and clears buffer
    .endm; .macro \self\().push, va:vararg=\self; stack.push \self, \va

# pop works with stack buffer, so both self and self.pop are updated
    .endm; .macro \self\().pop, va:vararg=\self\().pop; stack.pop \self, \va

# popm is a version of pop that discards the current buffer value and works only from stack memory
    .endm; .macro \self\().popm, va:vararg; \self\().pop;.ifnb \va; stack.pop \self, \va;.endif

# de-queue works independently from stack buffer, so only self.deq is updated
    .endm; .macro \self\().deq, va:vararg=\self\().deq; stack.deq \self, \va

# iter is a special iterator method that invokes the .i and the .get methods
# - this in turn will trigger any custom callbacks plugged into .i and .get
    .endm; .macro \self\().iter, va:vararg=\self; stack.iter \self, \va


# convenience macros for assigning modes:
    .endm; .macro \self\().push.mode,  kw; \self\().mode oob_push, \kw
    .endm; .macro \self\().pop.mode,   kw; \self\().mode oob_pop, \kw
    .endm; .macro \self\().deq.mode,   kw; \self\().mode oob_deq, \kw
    .endm; .macro \self\().iter.mode,  kw; \self\().mode oob_iter, \kw
    .endm; .macro \self\().i.mode,     oob, idx
      .ifnb \oob; \self\().mode oob_i, \oob; .endif
      .ifnb \idx; \self\().mode idx_i, \idx; .endif

# end of method definitions
    .endm

    stack.mut \self
    # this makes the stack object easy to mutate after construction by adding the following methods:
    # - '.hook' for connecting to class-level default behaviors
    # - '.mode' for connecting to class-level mutations
    # - '.mut' for connecting to custom mutations defined by the user

    # end of method definitions

    \self\().push.mode  incr  # OOB pushes will extend the stack frame
    \self\().pop.mode   null  # OOB pops will produce null values
    \self\().deq.mode   null  # OOB deques will produce null values
    \self\().iter.mode  rot   # OOB iterations will rotate to top/bottom of stack
    \self\().i.mode     rot, range   # index mode will rotate when out of bounds of s...q
    # these create default modes for push, pop, deq, and iter 'out of bounds' exception behaviors
    # - these connect to the class-level 'stack.mut.oob_*' callback methods
    # - they can be mutated by invoking the same syntax after construction with different keywords

    \self\().mut , i_plugin, get_plugin, set_plugin, iter_plugin, push_pre, push_post
    # creates no-op default behaviors for plugins for methods related to the i index
    # - these can be modified later to plug user-defined functionality into [i]

  .endif
.ifnb \varg; stack \varg; .else; .irp ppt,fill,size,;stack.\ppt = 0; .endr; .endif
# reset constructor argument properties after constructing all varargs


# --- static methods:

.endm; .macro stack.fill, self, start, size, fill; LOCAL i, idx#
  idx = \start; i = \size; .if \self\().sss < (idx+i); i = \self\().sss - idx; .endif
  .if (idx <= \self\().ss) && (\self\().ss < (idx+i)); \self\().ss = idx+i; .endif
  .if i > 0; .rept i;sidx.ema \self, %idx, <=\fill>;idx=idx+1;.endr; .endif

.endm; .macro stack.reset, self, fill, start, size
  \self\().q = \start; \self\().s = \self\().q + \size;
  .ifnb \fill; stack.fill \self, \self\().q, \size, \fill; .endif
  .if \self\().q < \self\().qq; \self\().q = \self\().qq; .endif
  .if \self\().s > \self\().ss; \self\().s = \self\().ss; .endif

.endm; .macro stack.push, self, va:vararg;  ifalt; stack.memalt = alt; .altmacro
  .irp val,\va;
    .ifnb \val
      \self\().hook.push_pre \val
      .if \self\().s < \self\().sss
        .if \self\().s >= \self\().ss; stack.oob=1; \self\().hook.oob_push \val; .endif
        .if stack.oob==0;
          sidx.ema \self, %\self\().s, <=\val>
          \self\().s = \self\().s + 1;  \self = \self\().fill;
          \self\().hook.push_post \val; .endif;
    .endif; .endif; stack.oob=0
  .endr; ifalt.reset stack.memalt; stack.oob=0

.endm; .macro stack.pop, self, va:vararg; ifalt; stack.memalt = alt; .altmacro
  .irp sym,\va
    .ifnb \sym
      .if \self\().s <= \self\().q
        stack.oob=1; \self\().hook.oob_pop \sym; .endif
      .if stack.oob==0; \self\().pop = \self; \sym = \self
        \self\().s = \self\().s - 1; sidx.ema <\self = \self>, %\self\().s; .endif
    .endif; stack.oob=0;
  .endr; ifalt.reset stack.memalt; stack.oob=0

.endm; .macro stack.deq, self, va:vararg; stack.memalt = alt; .altmacro
  .irp sym,\va
    .ifnb \sym; stack.oob=0
      .if \self\().q+1 >= \self\().s
        stack.oob=1; \self\().hook.oob_deq \sym; .endif
      .if stack.oob==0; sidx.ema <\self\().deq=\self>, %\self\().q
      \sym = \self\().deq; \self\().q = \self\().q + 1; .endif
    .endif; stack.oob=0
.endr; ifalt.reset stack.memalt; stack.oob=0

.endm; .macro stack.iter, self, va:vararg
  .irp sym,\va
    .ifnb \sym;
      stack.idx = \self\().i + \self\().step
      .if stack.idx >= \self\().s; stack.oob=1
      .elseif stack.idx < \self\().q; self.oob=1; .endif
      .if stack.oob; \self\().hook.oob_iter \sym; .endif
      .if stack.oob==0; \self\().i = stack.idx
      \self\().iter = \self; \sym = \self; \self\().get;
      \self\().hook.iter_plugin \sym;.endif
    .endif; stack.oob=0
  .endr; stack.oob=0



# Static mutable behaviors for iterator methods
# - these are the defaults that are used if not overridden by user mutations:



# Static mutable behaviors, for out of bounds exception handling:
# - these create the various 'modes' for I/O methods

# --- NOP - Read/Write
.endm; .macro stack.mut.oob_push.nop, self, va:vararg; stack.oob=0
.endm; .macro stack.mut.oob_pop.nop, self, va:vararg; stack.oob=0
.endm; .macro stack.mut.oob_deq.nop, self, va:vararg; stack.oob=0
.endm; .macro stack.mut.oob_iter.nop, self, va:vararg; stack.oob=0
# 'nop' mode keywords, for no action on both read and write OOB


# --- ROT - Read/Write
.endm; .macro stack.mut.oob_push.rot, self, sym, va:vararg
  \self\().s = \self\().qq; stack.oob = 0
  .if \self\().q > \self\().s; \self\().q = \self\().s; .endif

.endm; .macro stack.mut.oob_pop.rot, self, sym, va:vararg
  \self\().s = \self\().ss; stack.oob = 0

.endm; .macro stack.mut.oob_deq.rot, self, sym, va:vararg
  sidx.ema <\self\().deq=\self>, %\self\().q; \sym = \self\().deq; \self\().q = \self\().qq

.endm; .macro stack.mut.oob_iter.rot, self, sym, va:vararg
  stack.idx = stack.idx - \self\().q; stack.oob=0
  .if stack.idx; stack.idx = stack.idx % (\self\().s - \self\().q);.endif
  .if stack.idx < 0; stack.idx = \self\().s + stack.idx
  .else; stack.idx = stack.idx + \self\().q; .endif;
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

.endm; .macro stack.mut.oob_iter.null, self, sym, va:vararg
  \sym = \self; \self = \self\().fill
# 'null' mode keywords, for producing a fill value when reading OOB
# - this will use the .fill property (0 by default) to give you a 'null' instead of a memory value


# --- CAP - Read-only
.endm; .macro stack.mut.oob_pop.cap, self, va:vararg
  \self\().s = \self\().q+1; stack.oob=0

.endm; .macro stack.mut.oob_deq.cap, self, va:vararg
  \self\().q = \self\().s-1; stack.oob=0

.endm; .macro stack.mut.oob_iter.cap, self, va:vararg
  \self\().i = \self\().s-\self\().step; stack.oob=0

# 'cap' mode keywords, for undoing the iteration of a count that reads OOB
# - this will subtract index step that was just made so that the final element is re-read


# --- i INDEX MODES - i index methods handle how input is interpreted before checking for oob
.endm; .macro stack.mut.idx_i.range, self, idx, va:vararg
  \self\().hook.oob_i (\idx + \self\().q); \self\().hook.i_plugin \idx, \va
.endm; .macro stack.mut.idx_i.rel, self, idx, va:vararg
  \self\().hook.oob_i (\idx + \self\().i); \self\().hook.i_plugin \idx, \va
.endm; .macro stack.mut.idx_i.abs, self, idx, va:vararg
  \self\().hook.oob_i \idx; \self\().hook.i_plugin \idx, \va

# --- i OOB CHECKS
.endm; .macro stack.mut.oob_i.nop, self, idx, va:vararg;  \self\().i = \idx
.endm; .macro stack.mut.oob_i.rot, self, idx, va:vararg
  \self\().i = \idx - \self\().q
  .if \self\().i; \self\().i = \self\().i % (\self\().s - \self\().q);.endif
  .if \self\().i < 0; \self\().i = \self\().s + \self\().i
  .else; \self\().i = \self\().i + \self\().q; .endif
.endm; .macro stack.mut.oob_i.cap, self, idx, va:vararg
  \self\().i = \idx; .if \self\().i >= \self\().s; \self\().i = \self\().s - 1; .endif
  .if \self\().i < \self\().q; \self\().i = \self\().q; .endif
.endm
.endif
/**/
