# --- Argument Item Buffer Objects
#>toc str
# - a scalar buffer object pseudo-class that can efficiently store `:vararg` items
# - useful for creating iterators that do not attempt to evaluate the contents
#   - buffers are similar to `str` objects, but are much lighter-weight and less featured

# --- Example use of the items module:

.include "punkpc.s"
punkpc items
# Use the 'punkpc' statement to load this module, or include the module file directly


# --- APPENDING ITEMS ---

# 'items' is a class-level object available for generic use
# It has a method and a property both called 'items'

# The method works with the buffer it is currently pointing to in the property



# We use the 'items' method to interact with this buffer

# The first argument is an input macro name used to emit the buffer contents:
# -  items  macro, ...
# If the 'macro' arg is blank, then '...' will be appended to the buffer instead of emitted


# This can be done by calling items with a comma ',' as the first argument:

items , a, 1, .
#     ^
# The buffer 'items' has been appended with 3 items:  a, 1, .
# - the starting comma makes the first argument blank, triggering this 'append' buffer syntax

.long items
# >>> 1
# The value in the property 'items' is just a pointer to the buffer containing these items
# As an object created by the class module, it will usually have the value of '1' unless changed


pointer = items
# We can copy this pointer to another symbol...

items.append pointer, a, a
# ... and use the class-level 'items.append' method to write to the corresponding buffer




# --- EMITTING ITEMS ---

# We now have a buffer with 'a, 1, ., a, a' queued in its vararg output buffer
# - each of these is a valid expression, so we can output them using just a directive like '.long'

a = 5
# by assigning a value to 'a', we allow it to be interpreted as an expression


items .long
# >>> 5, 1, 12, 5, 5
# All queued values have been emitted from the buffer using '.long'
# - .long is a directive that accepts comma-separated lists

a = .
# The 'a' symbol has been changed from 5 to the current value of '.'
# The '.' symbol will evaluate as the current location in the assembly (emitted bytes)
# - the resulting output from reading this buffer will now also change, when invoked

items .long
# >>> 24, 1, 32, 24, 24
# ... unlike evaluated symbol expressions, these items are not interpreted until emitted!
# - this makes them useful for storing variables in a tuple that can be parsed in a later context




# --- CLEARING ITEMS ---

# With a pointer property and a method that uses it, 'items' is like a tiny object
# - their only purpose is to provide a 'method' for interfacing with a buffer

items
# Call the object's method without any args to trigger a reset check:
#  - If the object is currently using its own buffer, then it will clear it
#  - If the object is using some other buffer, then it will revert back to its main one

# This technically unallocates and reallocates the buffer used by 'items'

items, 5
items .long
# >>> 5
# The buffer has been given a blank start for appends, discarding the old contents as garbage memory


# NOTE: If we modify the pointer value in 'items', then doing this will not clear the buffer
# - instead, the object will reset its pointer back to the buffer it is in charge of managing
# - in the case of the items object, this will always start off as an ID of '1'

items = 2
# By changing it to a different value...

items
# ... and attempting to clear it ...

items, 6
items .long
# >>> 5, 6
# ... we just get the old buffer back, and start operating on its old state.
# This is the only buffer that the 'items' method is allowed to clear on its own.



# Another way of clearing the buffer is to simply set the pointer value to null, '0'

items = 0
# The buffer still exists, but attempting to use the 'items' method again will clear it before use

items, 7
items .long
# >>> 7
# The buffer only gets cleared once we call it -- after it finds the null





# --- METHOD OBJECTS ---

# We can create new objects for managing separate buffers using the 'items.method' constructor:


items.method myArgs
# This creates a new method called 'myArgs'
#   since we didn't give it a property name, it has a property that is also called 'myArgs'



myArgs, 1, 2, 3, 4, 5, a
myArgs .long
# >>> 1, 2, 3, 4, 5, 24
# This new object 'myArgs' behaves just like 'items' -- but with a discrete buffer



# The 'myArgs' method only interacts with a buffer by pointing to it, so we can change the pointer:

myArgs = items
# Copy the pointer being used by 'items' ...

myArgs, 1
items .long
# >>> 7, 1
# This causes 'myArgs' to temporarily interact with the 'items' buffer instead of its own buffer
# - You can see this because the old buffer [7] was a appended instead of [1, 2, 3, 4, 5, a]


myArgs        # Call with no args to restore old buffer pointer
myArgs, 0
myArgs .long
# >>> 1, 2, 3, 4, 5, 6, 0
# Calling the method with no args while using a different buffer causes it to recover the old buffer


myArgs        # Call again with no args to clear old buffer
myArgs, 2
myArgs .long
# >>> 2
# Calling the method with no args while using its own buffer will clear its buffer memory
# - this can be used to manage temporary buffers that you are finished using
# - if creating many objects using buffers, you may use this to optimize memory efficiency in GAS





# --- ALLOCATING BUFFERS ---

# You don't need to make a new method for each buffer, since they can be plugged in via pointer
# In fact, method objects are only a convenience -- pointers can be used at the class-level:

items.append myArgs, 3
items.emit myArgs, .long
# >>> 2, 3
# This is just like calling 'myArgs' -- but without directly invoking an object method


# To create buffers that aren't managed by a method object, we can use 'items.alloc':

items.alloc x, y, z
# This creates 3 new buffers, and references them in symbols called 'x', 'y', and 'z'


# Manual allocations like this are not managed automatically, but can be used at the class-level

items.append x, 1, 2
items.append y, 2, 3
items.append z, 3, 4
items.emit x, .long
items.emit y, .long
# >>> 1, 2, 2, 3
# Each has its own discrete memory that we can manipulate separately from the other buffers

myArgs = z
myArgs, 5
myArgs .long
# >>> 3, 4, 5
# By plugging one of the pointers into a method object, we can temporarily use it from that method

myArgs
# By then calling that method without any args, we can recover its old pointer value

myArgs .long
# >>> 2, 3
# (the old buffer is back)

items.emit z, .long
# >> 3, 4, 5
# Doing this doesn't clear the temp buffer, since it doesn't belong to the method object
# - the temp buffer must therefore be managed externally by some means, if at all

.long items.free, items.alloc
# >>> 0, 5
# You can check to see how many instances are allocated at (or freed) with these properties
# We currently have 5 buffers allocated: 'items', 'myArgs', 'x', 'y', and 'z'




# --- FREEING BUFFERS ---

# Manually allocated buffers with 'items.alloc' will not be cleared by any methods
# While not too important to manage externally; unaccounted allocations may add up as memory leaks


# To destroy them, you must use 'items.free' to put them in them back into buffer heap:

items.free x, y, z
# These pointers have been nullified, and their corresponding buffers have been purged
# - any copies of these pointers are now invalid, and point to garbage memory that will be recycled


# This can be thought of as 'clearing' a buffer that isn't using a method object
# You must reallocate a buffer to a pointer that has been cleared in this way, to use it again


.long items.free, items.alloc
# >>> 3, 2
# As you can see, freeing these buffers has put them in the 'items.free' stack, for reallocation
# - only 'items' and 'myArgs' are still available in the environment

items.alloc i, j
.long items.free, items.alloc
# >>> 1, 4
# Allocating new buffers generates the buffering method necessary to operate it via pointer
# - old buffers that were pointed to by 'x' and 'y' are now new buffers for 'i' and 'j'
# - 'reallocation' is handled automatically by the allocator method


items.method i
.long items.free, items.alloc
# >>> 1, 4
# Since the 'i' symbol already contains a value, it is assumed to have a pointer to a buffer
# This causes the creation of methods over existing pointers to not allocate an extra buffer
# - this prevents the old buffer pointer in 'i' from becoming inaccessible




# --- NEGATIVE AND NULL POINTERS ---

# You've seen how the 'items' pointer can be nullified with 0 to force it to clear on next use...

myArgs = 0
myArgs, 1, 2
myArgs .long
# >>> 1, 2

myArgs = 0
myArgs, 3, 4
myArgs .long
# >>> 3, 4
# ... the same is true of the main buffer in any method object
# Objects that are given a pointer of '0' will clear their main buffer and make a new one on use
# - this effectively starts a new blank buffer by assigning a new pointer to the method's identity



# Another form of null is a negative number, like '-1'

myArgs = -1
myArgs, 5, 6
myArgs .long
# >>> nothing is emitted here!
# When a negative number is detected, it is handled by not doing anything at all


# This alternative null format is useful for creating harmless blanks in your parsing operations
# Negation however has the extra feature of being able to 'disable' existing pointers

# By negating a positive pointer, sign is encoded into the pointer without destroying the value:

myArgs = i
# myArgs is now using the 'i' buffer we generated earlier

myArgs, 1, 2, 3, 4
i .long
# >>> 1, 2, 3, 4
# Writing to it will write to the same buffer being used by the 'i' object

myArgs = -myArgs
# Now, the pointer is negated

myArgs, 5, 6
i .long
# >>> 1, 2, 3, 4
# Writing to the buffer no longer does anything, because of the negative pointer

i, 7, 8
i .long
# >>> 1, 2, 3, 4, 7, 8
# Using the 'i' object directly doesn't do this, because the pointer property isn't negated there

myArgs = -myArgs
# Negating it again toggles the pointer back on

myArgs, 9, 10
myArgs .long
# >>> 1, 2, 3, 4, 7, 8, 9, 10



# When attempting to use nulls of either kind (null or negative) with class methods ...

items.append 0, 0, 1, 2, 3
items.emit 0, .long
# >>> ... nothing is emitted





# --- ITEM ITERATORS ---

# Instead of using a directive like '.long' or '.byte' to emit item arguments, we can use a macro


# This macro will 'handle' the list by consuming the items in the given queue, recursively
# - this means that it will call itself until all items have been parsed

.macro myIter, dest, base=0, mul=1, rshift=0, add=0, va:vararg
# This macro definition has 5 arguments plus a ':vararg' keyword to store args still in the queue
# - each iteration will make the assignment  dest = ((base * mul) >> rshift) + add

  .ifnb \dest
    # The macro only operates if the 'dest' argument isn't blank
    # - this causes recursion to stop when a blank destination (end of queue) is found

    \dest = ((\base * \mul) >> \rshift) + \add
    # Any blank arguments are given their defaults

    .long \dest
    # emit the value, so we can see it

    myIter \va
    # call self with only the unused arguments in the queue
    # - this consumes items in the stack 5 at a time until it runs out of assignment destinations

  .endif
.endm  # - we can use this macro to handle items in place of '.long', like we've been doing


myArgs = 0
myArgs, val$0, a, b, c, d
myArgs, val$1, b, c, d, e
myArgs, val$2, c, d, e, f
# Clear 'myArgs' and append some argument tuples for 'myIter' to parse

a =  4
b =  3
c =  2
d =  1
e =  0
f = -1
# All of the variables within the tuples we made are affected by these assignments

myArgs myIter
# >>> 4, 3, 1
#   4 = ((4 * 3) >> 2) + 1
#   3 = ((3 * 2) >> 1) + 0
#   1 = ((2 * 1) >> 0) - 1
# The resulting evaluations from the iterator use the current value of each given variable




# --- LOOP ITERATORS ---

# If you have a macro that can handle your items one at a time, a loop iterator is all you need
# - macros are good for handling arguments in tuples, but have a finite limit to their recursion
# - loops don't suffer the recusion limit, but can only process items one at a time

# Two loop iterators are included with the module as 'items.irp' and 'items.irpc':
# - .irp will pass each comma-separated item to a macro, for handling
# - .irpc will pass each character in the buffer to a macro, for handling


show_errors = 0
# Set this to 1 to see the errors generated in this example

.if show_errors

  items = 0
  items, "Hello", "World"
  # Quotes will be preserved on output...

  items.irp items, .error
  # >>> Error: Hello
  # >>> Error: World
  # - '.error' directive is invoked once for each item

.endif

# --- Example Results:

## 00000001 00000005
## 00000001 0000000C
## 00000005 00000005
## 00000018 00000001
## 00000020 00000018
## 00000018 00000005
## 00000005 00000006
## 00000007 00000001
## 00000002 00000003
## 00000004 00000005
## 00000018 00000007
## 00000001 00000001
## 00000002 00000003
## 00000004 00000005
## 00000018 00000000
## 00000002 00000002
## 00000003 00000001
## 00000002 00000002
## 00000003 00000003
## 00000004 00000005
## 00000002 00000003
## 00000003 00000004
## 00000005 00000000
## 00000005 00000003
## 00000002 00000001
## 00000004 00000000
## 00000005 00000001
## 00000002 00000003
## 00000004 00000001
## 00000002 00000003
## 00000004 00000001
## 00000002 00000003
## 00000004 00000001
## 00000002 00000003
## 00000004 00000007
## 00000008 00000001
## 00000002 00000003
## 00000004 00000007
## 00000008 00000009
## 0000000A 00000004
## 00000003 00000001
