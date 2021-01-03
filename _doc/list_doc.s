# --- List Objects
# Extension of the Stack object type
# Allows for additional indexing methods, an internal [i] index, and an iteration method


# --- Updates:

# version 0.0.1
# - split off from the old 'stack' module with methods for 'list' objects
# - added to punkpc library


# --- Example use of the list module:

.include "punkpc.s"
punkpc list
# Use the 'punkpc' statement to load this module, or include the module file directly



# --- PUSHING VALUES TO SCALAR MEMORY
# Lists create a 'scalar variable' out of the object name you give the constructor 'list'

list a
# 'a' is now tied to a list of indexable symbols, and can write to it like a list
# - the list will grow as new values are listed, and is called the list 'memory'

a = 1
# 'a' is like a normal symbol that you can assign values to, and use later on in expressions

a.push
.long a
# >>> 0
# 'pushing' a value like this will cause the value of 'a' to be memorized
# - this causes a fill value to overwrite the buffer variable, which is '0' by default

a.push 2, 3, 4
# you can bypass the variable entirely by just providing the values you want to list as args
# - this causes the values 2, 3, and 4 to be listed on top of the previously pushed value, 1

.long a
# >>> 0
# the buffer is blank still because we have not read from the list memory that was pushes

##            LIST
# [ VAL ] -> [ NEW ]  - (.push copies a value to top of memory list)
#            [ MEM ]
#            [ MEM ]  - (old memory from prior pushes)
#              ...

a = 5
# It's called a 'list' because it keeps the top-most value in the system randomly accessible
# - by writing to 'a', it's as though we're writing to what is pending a write to list memory

##            LIST
#              a=5    - (pending storage to memory... can be actively read/written to)
#            [  4  ]  - (first memory value is currently in storage)
#            [  3  ]
#            [  2  ]
#            [  1  ]



# --- POPPING OUTPUT VALUES FROM MEMORY
# You can retrieve memory from the list by popping with the '.pop' object method

a.pop
.long a
.long a.pop
# >>> 4, 5
# 'popping' a value off the list will copy the value of 'a' over to the .pop property
# 'a' is then updated to copy the previously indexed list memory value
# - this allows you to use 'a' like a scalar variable that updates with .pushes and .pops
# - OR it allows you to use 'a.pop' to include the currently buffered value in stream

##            LIST
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

##           LIST
#              X
#              X
#              X
# [.POP ] <-  a=0    - (popping at bottom of list triggers OOB exception)

# By default, this is handled by providing a fill value, '0' in this case
# - see the 'modes' and 'mutators' examples for info on other exception handling methods



# --- LIST INDEX
# The list is just an interface for randomly accessible memory.
# An [s] index is built into list objects in order to keep track of the top memory symbol

# Popping consumes memory in the list only by subtracting from [s]
# - the value in memory is not actually destroyed until another value is pushed over it
#   - you may recover popped memory values by adjusting the list index and popping again

a.s[4]
# The '.s' object method is the 'list' index method -- we can influence s with it
# - in this case, [4] references the top of our currently listed values

a.pop
.long a
# >>> 4
# We set the list [s] index to 4, and popped the corresponding value back from memory!
# - this only works for values you have not overwritten with another push

.long a.s
# >>> 3
# The '.s' property is the property that gets edited by the '.s' method
# - it can be read or written to in order to interface with current list index
# - it has just popped from 4 down to 3

.long a.ss
# >>> 4
# The '.ss' property is a record of the highest-written index in memory
# - we could have used this in place of explicitly stating [4] before popping

a.s
.long a.s
# >>> 4
# Alternatively, invoking '.s' without any arguments will cause it to default to '.ss'
# - this can be used to automatically reset your list index to its highest possible value



# --- LISTS AS QUEUE OUTPUTS
# Popping values causes them to be consumed from the list in a 'First Out' order
# - this essentially causes the order to be reversed when reading memory
#   - this is a desirable trait when using a list variable to recover a previous memory state
#   - this may not be desirable if you wish to recall your elements in the order they were listed

# You can instead read from list memory as though were a 'queue' to pop in a 'Last Out' order

.long a.q
# >>> 0
# A [q] index is built into list objects just like the [s] index, to make a working memory range
# - by default it's 0 and can't safely go negative

a.deq x, y
.long x, y
# >>> 1, 2
# the '.deq' object method is an alternative to '.pop' that allows you to 'dequeue' elements
# - this returns them in the order they were listed in, unlike '.pop'

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
# With lists and queues, you can easily make pipes for process buffered information

list b
# create a second list object, 'b'
# - this list will be used to buffer the outputs of an output made from 'a'

a.s
# reset list index of a to highest written memory

.rept a.s  # for each index in [s]
  a.pop
  b.push a # list popped 'a' elements into 'b' list
.endr

a.s
.rept a.s
  a.deq b  # list dequeued 'a' elements into 'b' list
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

##             LIST
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
# Since lists are based on the 'sidx' punkpc library, they are technically dictionaries
# - the list interface is just an implementation of this dictionary

# You may directly access list memory by using the indexed symbol names made for memory values
# These are the name of the list object plus a '$n' suffix, where n is a decimal number

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
# You may also set memory in this manner, ignoring the list boundary

a.s[8]
.long a.s
# >>> 4
# Setting memory like this does not update the list index
# - the '.s' method will not push beyond its highest memory

a.ss[8]
.long a.s
# >>> 8
# The '.ss' method can be used to force a list index to push the highest memory index
# - if not careful, this may lead to gaps in your list that are not valid for reading
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
# The list index is considered exclusive in the [i] range, so it will rotate back to [q]

a.q[1]
a.i[0]
a.get
.long a
# >>> 2
# Raising [q] will raise the base index applied to [i] inputs



# --- LISTS AS ITERATORS
# Lists can be used like iterators with the [i] index, and the '.iter' output pipe

a.q[0]
a.get[0]
# the buffer 'a' will be used in the iter process, like when popping

a.step = 1
# unlike popping, the [i] index uses a custom step value that can be positive or negative
# - this allows you to create an outpipe stream that uses 'a' and doesn't change the list index

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




# --- LIST MODES
# List methods use mutable hooks that can be changed with the '.mode' object methods
# The most common is a hook used to handle various 'out of bounds' exception cases

a.reset
a.push 1, 3, 3, 7
# reset list memory and push some new values


.rept a.s<<1 # for twice as many pushed numbers in memory...
  a.deq      # ... attempt to pop memory
  .byte a.deq
.endr
# >> 1, 3, 3, 7,   0, 0, 0, 0
# The default behavior when popping out of bounds is to generate a 'null' fill value
# - by default, '.fill' = 0

a.s[4]
# Default behavior resets the list once dequeued all the way, so we reset the index

a.mode oob_deq, rot
# By setting the mode 'oob_deq' to a new keyword, we can change this OOB behavior

a.q
.rept a.s<<1
  a.deq
  .byte a.deq
.endr
# >>> 1, 3, 3, 7,   1, 3, 3, 7
# dequeueing in 'rot' mode causes overflows to be handled by resetting [q], repeating itself


a.mode oob_deq, cap
a.q  # reset [q] = [qq]
.rept a.s<<1
  a.deq
  .byte a.deq
.endr
# >>> 1, 3, 3, 7,   7, 7, 7, 7
# dequeueing in 'cap' mode causes overflows to freeze at the final available value

a.mode oob_deq, nop
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

a.mode oob_i, nop
a.mode idx_i, abs
a.i
a.get
.long a
# >>> 1
# with no arguments, .i uses [0]
# in 'nop' mode, i will basically ignore OOB cases
# in 'abs' mode, i will not be relative to [q], and will use the input idx directly
# - this makes it behave more like [q] or [q]




# --- LIST POINTERS
# Lists use their self property as a buffer, so they can't be referenced just by name as pointers
# However, the '.is_list' property can be copied and used like a pointer with 'stack.point'

list a, b, c
a = 0x10; b = 0x20; c = 0x30
# set up lists 'a', 'b', and 'c' to buffer initial values

myPointer = a.is_list
# this saves the pointer ID associated with list 'a'

stack.point myPointer, .long
# >>> 0x10
# Invoking the pointer with 'stack.point' will show what's currently buffered in the saved pointer
# The argument '.long' is the name of macro or directive that handles the returned object name
# - this lets you reference a scalar through the use of an ID that can be saved in a symbol
#   - the above 'stack.point' statement is just like typing '.long a'


# It's entirely possible to create a 'list of lists' this way:

list lists
lists.push a.is_list, b.is_list, c.is_list
# 'lists' pushes the pointer of 'a', 'b', and 'c' into its memory

lists.pop
stack.point lists, .long
# >>> 0x30

lists.pop
stack.point lists, .long
# >>> 0x20

lists.pop
stack.point lists, .long
# >>> 0x10
# The pointers stored in 'lists' can be used to invoke the saved lists 'a', 'b', and 'c'

a.push 0x100, 0x200, 0x300
a.pop
stack.point lists, .long
# >>> 0x300
# The value of the referenced list buffers can change and the pointer will still resolve correctly


# --- Module attributes:

# --- Class Methods ---
# --- stack.i     obj, idx, ...
# --- stack.get   obj, idx, sym, ...
# --- stack.get   obj, idx, val, ...
# --- stack.iter  obj, sym, ...
# class-level methods for handling object-level args



# --- List Objects ---

# --- list   name, ...
# List objects are extensions of lists that provide an [i] index


# --- List Properties:
  # - extends stack properties...

  # --- .i        - iter index  -- the current index of this iteration, or last get/set
  # --- .iter     - outpipe memory of last iterated value (from self buffer)
  # --- .step     - step size   -- the number of steps that .i takes on each iteration



# --- List Methods:
  # - extends stack methods...

  # --- .iter   sym, ...
  # Copy self to iter stream output, and update self with nth memorized push value
  # - the sequence will use the .step value to increment/decrement the index in linear steps
  # - if no symbol is given, self.iter is used for output stream
  # - multiple symbols will cause iterated values to be assigned to each, in a sequence

  # --- .get     idx, sym, ...
  # Get a list value by invoking a random-access sidx.get operation
  # NOTE: this method is very fast, but not safe if the given index has not been written to yet!
  # - assigns gotten value to self buffer
  # - if idx is blank, then .i is used
  # - if sym is blank, then self is used
  # - if multiple symbols are provided, values will be gotten in a sequence using .step

  # --- .set     idx, val, ...
  # Set a list value by invoking a random-access sidx.set operation
  # - if 'val' is blank, then value in self buffer is used
  # - works like .get, syntactically


  # --- .i   idx, ...
  # List index method
  # - contains a dummy hook, for overriding and adding functionality
  #   - ... is passed to the dummy hook, but not used by the index method directly
  # - without mutation, this is no different than literally assigning .i



  # stack index methods are also provided at the object level, unlike stack objects themselves
  # - these are normally only available to stacks at the class-level -- but not for lists:

  # --- .q   idx
  # Queue index method
  # - sets index self.q
  # - if no index is given, lowest memory index is used
  # - caps in range self.qq ... self.s

  # --- .s   idx
  # List index method
  # - sets index self.s
  # - if no index is given, highest memory index is used
  # - caps in range self.q ... self.ss

  # --- .ss idx
  # A variation of '.s' that can push '.ss' if out of bounds
  # - caps in rage of self.q ... self.sss



# --- List Modes ---
# - extends stack modes...

# Use '.mode' to set these keyword combinations '\hook, \mode' manually
# - each of the following is a \hook, \mode  keyword combination



  # Object Method Overrides:
  #     hook   mode
  # --- i,     default
  # --- iter,  default
  # --- get,   default
  # --- set,   default
  # Set these to a custom mode/mutator to override default behaviors
  # - use 'stack.mut.(hook).default' to call these directly for extending the default behavior



  # Index Modes:
  # --- idx_i,     range  -- i default
  # 'range' index mode interprets inputs as relative to [q], and limited by [q] ... [s]

  # --- idx_i,     rel
  # 'rel' index mode is like range, but input is added to current index to make a relative index

  # --- idx_i,     abs
  # 'abs' index mode uses inputs directly, but still invokes OOB errors if inputs are out of range




  # Out-Of-Bounds (oob) Exception Modes:
  # - behaviors for handling navigations that move out of index limitations

  # --- oob_iter,  nop
  # --- oob_i,     nop
  # 'nop' mode keywords, for no action on both read and write OOB

  # --- oob_iter,  rot  -- iter default
  # --- oob_i,     rot  -- i default
  # 'rot' mode keyword, for rotating back to opposite side of memory range

  # --- oob_iter,  null
  # 'null' will freeze the list index, and produce blank 'fill' values in pop stream

  # --- oob_iter,  cap
  # --- oob_i,     cap
  # 'cap' mode keywords, for undoing the iteration of a count that reads OOB
  # - this will subtract index step that was just made so that the final element is re-read




# --- List Hooks ---
# - extends stack hooks...

# Use '.mut' with these keywords to assign new macros in place of default hooks
# - Mutators will be called like callbacks, with the following provided arguments

  # --- i         self, ...
  # --- get       self, ...
  # --- set       self, ...
  # --- new       self, ...
  # --- iter      self, ...
  # Override these to completely change the corresponding methods

  # --- oob_iter  self, sym, ...
  # --- oob_i,    self, idx, ...
  # --- idx_i     self, idx, ...
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
## 00000003 00000002
## 00000001 00000000
## 00000001 00000002
## 00000003 00000004
## 00000005 00000006
## 00000007 00000008
## 00000004 00000008
## 00000001 00000008
## 00000001 00000002
## 00000001 00000002
## 00000004 00000003
## 01030307 00000000
## 01030307 01030307
## 01030307 07070707
## 01030307 05060708
## 01030307 01030307
## 00000007 00000001
## 00000010 00000030
## 00000020 00000010
## 00000300




