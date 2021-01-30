# --- Stack Objects
# Create objects that can stack values, and pop or de-queue them
# Stack objects use 'self' like a normal symbol that can be treated like a scalar variable
# - this scalar variable interacts with the stack structure using object methods that can be called


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


# --- Example use of the stack module:

.include "punkpc.s"
punkpc stack
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

stack.s a, 4
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

stack.s a
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

stack.s a
# reset stack index of a to highest written memory

.rept a.s  # for each index in [s]
  a.pop
  b.push a # stack popped 'a' elements into 'b' stack
.endr

stack.s a
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

sidx.get a, 2
a = sidx
.long a
# >>> 3





# --- CLASS LEVEL ITERATORS
# You may call the class-level 'stack.rept' method to iterate through a stack's contents

stack  my_set
my_set.push  1, 3, 5, 7, 9, 11, 13, 15
# the range of 'my_set' is currently 8, from '.q' to '.s'

stack.rept  my_set, .byte
# >>> 1, 3, 5, 7, 9, 11, 13, 15
# This passes they symbols associated with stack memory in 'my_set' to the '.byte' directive
# - it reads from the current '.q' and '.s' index range, but does not modify them
# - each item is passed to the directive separately in an individual iteration in the sequence

stack.rept_range  my_set, [4], [6], .long
# >>> 9, 11, 13
# You can use a range specified entirely by arguments this way using the '.rept_range' variant
# - specified range is inclusive, and index is 0-based
# - brackets [] are optional

stack.rept_range  my_set, [6], [4], .long
# >>> 13, 11, 9
# If you specify a ceiling that is less than the floor index, then it will iter in reverse order





# --- STACK MODES
# Stack methods use mutable hooks that can be changed with the '.mode' object methods
# The most common is a hook used to handle various 'out of bounds' exception cases

a.reset
a.push 1, 3, 3, 7, 0xD, 0xE, 0xA, 0xD
stack.s a, 4
# reset stack memory and push some new values
# - the stack index is only at 4, but we ensure that there's 8 elements in memory


.rept a.s<<1 # for twice as many pushed numbers in memory...
  a.deq      # ... attempt to pop memory
  .byte a.deq
.endr
# >> 1, 3, 3, 7,   0, 0, 0, 0
# The default behavior when popping out of bounds is to generate a 'null' fill value
# - by default, '.fill' = 0

stack.s a, 4
# Default behavior resets the stack once dequeued all the way, so we reset the index

a.mode oob_deq, rot
# By setting the mode 'oob_deq' to a new keyword, we can change this OOB behavior

stack.q a
.rept a.s<<1
  a.deq
  .byte a.deq
.endr
# >>> 1, 3, 3, 7,   1, 3, 3, 7
# dequeueing in 'rot' mode causes overflows to be handled by resetting [q], repeating itself


a.mode oob_deq, cap
stack.q a
.rept a.s<<1
  a.deq
  .byte a.deq
.endr
# >>> 1, 3, 3, 7,   7, 7, 7, 7
# dequeueing in 'cap' mode causes overflows to freeze at the final available value


a.mode oob_deq, nop
stack.q a
.rept a.s<<1
  a.deq
  .byte a.deq
.endr
# >>> 1, 3, 3, 7,  D, E, A, D
# dequeuing in 'nop' mode causes overflows to try reading regardless of boundary error
# - nothing is done to stop the error, resulting in our old memory leaking through
# - if the old memory didn't exist, then this would just cause an error




# --- STACK POINTERS
# Stacks use their self property as a buffer, so they can't be referenced just by name as pointers
# However, the '.isStack' property can be copied and used like a pointer with 'stack.point'
stack a, b, c
a = 0x10; b = 0x20; c = 0x30
# set up stacks 'a', 'b', and 'c' to buffer initial values

myPointer = a.is_stack
# this saves the pointer ID associated with stack 'a'

stack.point myPointer, .long
# >>> 0x10
# Invoking the pointer with 'stack.point' will show what's currently buffered in the saved pointer
# The argument '.long' is the name of macro or directive that handles the returned object name
# - this lets you reference a scalar through the use of an ID that can be saved in a symbol
#   - the above 'stack.point' statement is just like typing '.long a'


# It's entirely possible to create a 'stack of stacks' this way:

stack stacks
stacks.push a.is_stack, b.is_stack, c.is_stack
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


# --- Module attributes:

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



## Binary from examples:

## 00000000 00000000
## 00000004 00000005
## 00000004 00000003
## 00000002 00000001
## 00000000 00000000
## 00000000 00000000
## 00000004 00000003
## 00000004 00000004
## 00000000 00000001
## 00000002 00000002
## 00000004 00000003
## 00000004 00000000
## 00000000 00000000
## 00000004 00000003
## 00000002 00000001
## 00000001 00000002
## 00000003 00000004
## 00000001 00000002
## 00000003 00000004
## 00000003 01030507
## 090B0D0F 00000009
## 0000000B 0000000D
## 0000000D 0000000B
## 00000009 01030307
## 00000000 01030307
## 01030307 01030307
## 07070707 01030307
## 0D0E0A0D 00000010
## 00000030 00000020
## 00000010 00000300




