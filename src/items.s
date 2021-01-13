/*## Header:
# --- Comma Separated Item Queues
# Minimal argument list buffer objects -- efficient memory/speed
# - For use with special :vararg macro args, and .irp or .irpc loops
# - uses no prereq modules for faster loading in standalone cases

##*/
##/* Updates
# version 0.0.1
# - added to punkpc module library
##*/
/*## Attributes:

# --- Class Properties ---
# --- items       - input/output property, for interacting with class methods
# --- items.free  - number of free items buffers
# --- items.alloc - number of allocated items buffers



# --- Constructor Method ---

# --- items.method   self, pointer_property
# Creates an object that manages and provides access to an items buffer
# Object only has one method, with an associated property and identity that is used by the method:

  # --- Method Object Property:
  # --- .is_items_method - object identity is the first assigned items buffer ID
  #                        - this points to an identifying buffer instance
  #                        - the ID may change each time a buffer is cleared
  # --- .\point - points to an items buffer - can be nullified
  #             - if pointer is 0, buffer will be cleared and a new one will be made on next call
  #             - if pointer is negative, method will be virtually disabled


  # --- Method Object Method:
  # Has 3 syntaxes, depending on which parts of the input are blank:
  # - attempting to use any of these with a negative pointer value will result in no operation
  # - attempting to use any of these with null pointer will 'clear' the obj buffer before use
  #   - 'clear' means to free the current buffer, and allocate a free one with blank memory
  #   - objects only 'clear' the buffer they are identifying with, in '.is_items_method'
  #     - objects will not clear other allocated buffers

  # --- (self)   macro, ...
  # Invokes 'items.emit' for the pointer in class property 'items'
  # --- (self)        , ...
  # Invokes 'items.append' for the pointer in class property 'items'
  # --- (self)
  # Clears this buffer, or re-points the pointer property to the one saved by object identity
  # - if the pointer is still pointing to the one made by this object, it is 'cleared'
  # - if the pointer is not pointing to the one made by this object, that pointer is recovered




# --- Class Methods ---

# --- items.alloc   pointer, ...
# Allocate an item buffer and point to it one for each given symbol name
# - 'pointer' becomes a pointer symbol that can be used in the other 'items' class methods
# - if there are any freed items buffers available, they will be reused before generating new ones

# --- items.free    pointer, ...
# Free an allocated item buffer vis pointer references
# - 'pointer' will be cleared, and item buffer it pointed to will be purged, and freed
# - freed buffers will be reused on next allocation(s)

# --- items.append  pointer, ...
# Appends items to item list pointed to by 'pointer'
# -   pointer -> [items, ...]

# --- items.emit    pointer, macro, ...
# Emit items as :varargs that trail behind '...' in a call to 'macro'
# -   macro  ..., [items]

# --- items.irp     pointer, macro, ...
# Emit items one at a time that trail behind '...' in a call to 'macro'

# --- items.irpc    pointer, macro, ...
# Emit characters one at a time that trail behind '...' in a call to 'macro'



# --- Class Level Object ---
# --- items - generic buffer, for volatile use



## Binary from examples:

## 00000001 00000005
## 00000001 00000000
## 00000005 00000005
## 00000000 00000001
## 00000000 00000000
## 00000000 00000005
## 00000005 00000006
## 00000007 00000001
## 00000002 00000003
## 00000004 00000005
## 00000000 00000007
## 00000001 00000001
## 00000002 00000003
## 00000004 00000005
## 00000000 00000000
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
## 00000004 00000001
## 00000004 00000001
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

##*/
/*## Examples:
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



##*/



.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module items, 1
.if module.included == 0
items.__free$ = 0
items.__mem$ = 0
items.alloc = 0
items.free = 0
items = 0


# some argument names have been obscured to prevent naming issues in altmacro escapes
#  __ prefixes have been added to some escape keywords


.macro items.method, self, __ppt
# protected argnames for altmacro usage

  .ifb \__ppt; items.method \self, \self; .exitm; .endif  # default property is self
  items.__altm # save state and enter altmacro mode

  .irp __slf, \self\().is_items_method
  # escape self property for ndef without any backslashes

    .ifndef __slf; \__slf = 0; .endif
    # catch undefined with ndef and a dummy macro, for purge step

    .ifndef __ppt; \__ppt = 0; .endif
    # free existing pointer

  .endr; .noaltmacro
  .if \__ppt; items.free \__ppt; .endif
  .if \self\().is_items_method == 0
    items.alloc \__ppt # allocate a fresh buffer for this pointer property
    \self\().is_items_method = \__ppt; .macro \self;.endm;
  .endif  # set obj id, if it doesn't already exist
  .purgem \self # purge old method (or dummy on first use)
  .macro \self, va:vararg; items.mut.method.default \self, \__ppt, \va; .endm
  items.__altm_reset # recover state
# -- This is a high level method constructor
# - it creates a small method object with a pointer property that can be changed to a new buffer

.endm; .macro items.mut.method.default, self, ppt, m, va:vararg;
  .if \ppt >= 0
    .ifb \m\va; items.mut.blank.default \self, \ppt
    .elseif \ppt==0; items.mut.null.default \self, \ppt
    .endif; .ifb \m; items.append \ppt, \va
    .else; items.emit \ppt, \m, \va
    .endif
  .endif

.endm; .macro items.mut.blank.default, self, ppt
    .if \self\().is_items_method == \ppt; items.free \self\().is_items_method; \ppt = 0
    .else; \ppt = \self\().is_items_method; .endif # handle case of blank args

.endm; .macro items.mut.null.default, self, ppt
  items.free \self\().is_items_method
  items.alloc \ppt
  \self\().is_items_method = \ppt # handle case of null pointer

.endm; .macro items.alloc, __va:vararg=items
  items.__altm
  .irp __obj, \__va
    .if items.__free$ <= 0; items.__new; .endif
    items.__em <items.__alloc \__obj, items.__free>, %items.__free$
  .endr
  items.__altm_reset
# -- This is a high level allocator method for making buffers that can be pointed to by method objs
# - you may create many pointers at a very low memory cost, and keep them separately from the objs
# - the objs may then be used to cycle between pointers by changing the pointer property



.endm; .macro items.free, __va:vararg=items
  items.__altm
  .irp __pntr, \__va
    .ifnb \__pntr
      .if (\__pntr > 0)
        items.__em <items.__free items.__mem> %\__pntr
        \__pntr = 0
      .endif
    .endif
  .endr
  items.__altm_reset
# -- This is buffer freer -- not a method object freer
# - use this to collapse the memory used by a previous buffer and recycle it for a new purpose
# - implementing this is only important if you expect to make a lot of (or very large) buffers



.endm; .macro items.append, __pntr=items, __va:vararg
  .if \__pntr > 0; items.__altm; .ifb \__va;
      items.__em2 <items.__mem>, %\__pntr, <.buf items.__append, items.__mem>, %\__pntr; .else;
      items.__em2 <items.__mem>, %\__pntr, <.buf items.__append, items.__mem>, %\__pntr, <,,\__va>
    .endif
  .endif
# -- This is a high level class method that can be used without instantiating a method object

.endm; .macro items.emit, __pntr=items, __mcro=items.__statement, __va:vararg
  .if \__pntr > 0;
    items.__altm
    items.__em <items.__mem>, %\__pntr, <.buf \__mcro,, \__va>
  .endif
# -- This is a high level class method that can be used without instantiating a method object

.endm; .macro items.irp, __pntr=items, __mcro, __va:vararg
  .if \__pntr > 0;
    items.__altm
    items.__em <items.__mem>, %\__pntr, <.buf items.__irp, \__mcro, \__va>
  .endif

.endm; .macro items.irpc, __pntr=items, __mcro, __va:vararg
  .if \__pntr > 0;
    items.__altm
    items.__em <items.__mem>, %\__pntr, <.buf items.__irpc, \__mcro, \__va>
  .endif
.endm; .macro items.__irp, __mcro, __va:vararg
  .irp __itm, \__va; .ifnb \__itm; \__mcro \__itm; .endif; .endr

.endm; .macro items.__irpc, __mcro, __va:vararg
  .irpc __itm, \__va; .ifnb \__itm; \__mcro \__itm; .endif; .endr




# --- hidden methods
.endm; .macro items.__statement, m, va:vararg; \m \va
# for defaulting to handle a list of items using the first item as a macro statement

# --- altmacro methods:

.endm; .macro items.__new
  items.__mem$ = items.__mem$ + 1
  items.__em <items.__mem>, %items.__mem$, <= items.__mem$>
  items.__em <items.__mem>, %items.__mem$, <.purgem = 0>
  items.__em <items.__build items.__mem>, %items.__mem$
  items.__em <items.__free items.__mem>, %items.__mem$
  # for creating new memory buffers

.endm; .macro items.__alloc, __obj, __pntr
  \__obj = \__pntr
  items.__em <items.__build items.__mem>, %\__pntr
  items.__free$ = items.__free$ - 1
  items.__update
  # for allocating a memory buffer from the free stack; generating new buffers if out of free ones

.endm; .macro items.__build, __self
  .if \__self\().purgem; .purgem \__self\().buf; .endif
  \__self\().purgem = 1
  .noaltmacro
  .macro \__self\().buf, m, arg, va:vararg;items.__altm_reset;\m \arg \va;.endm
  .altmacro
  # for building the first iteration of an items list
  # - can be used to clear while in altmacro mode

.endm; .macro items.__free, __self
  .if \__self\().purgem
    .purgem \__self\().buf
    \__self\().purgem = 0
    items.__free$ = items.__free$ + 1
    items.__em <items.__free>, %items.__free$, < = \__self>
    items.__update
  .endif
  # for purging buffers and updating the freestack metadata

.endm; .macro items.__append, __self, __varg:vararg
  \__self\().purgem = \__self\().purgem + 1
  .purgem \__self\().buf
  .noaltmacro
  .macro \__self\().buf, m, arg, va:vararg;items.__altm_reset;\m \arg \__varg \va;.endm
  .altmacro
  # for building post-initial iterations of an items list
  # - must be called with

.endm; .macro items.__update
  items.free = items.__free$; items.alloc = items.__mem$ - items.__free$
  # for updating the user level measures of allocated/free items buffers


.endm; .macro items.__em,p,i,s,va:vararg;\p\()$\i\s\va
.endm; .macro items.__em2,p,i,s,i2,s2,va:vararg;\p\()$\i\s\()$\i2\s2\va
# mimics parts of 'sidx' without the high-level stuff

.endm; .macro items.__altm
  .irp _altm,%1;items.__altm=0;.ifc \_altm,1;items.__altm=1;.endif;.endr; .altmacro
.endm; .macro items.__altm_reset
  .if items.__altm;.altmacro;.else;.noaltmacro;.endif;
  # mimics parts of 'ifalt' with independent memory

.endm
items.method items
.endif
