# --- Objects (and Classes)
#>toc Modules : objects and classes
# - a core module for defining classes that construct objects
# - objects are uniquely named
# - unique objects may be given pointer IDs, for identifying instances of a class
# - object methods may be defined through hook callers, for creating mutable behaviors
#   - mutable object methods may be reached via pointers, at the class level
# - object properties may be given hidden names, used internally by the constructor

# --- Example use of the obj module:

.include "punkpc.s"
punkpc obj
# Use the 'punkpc' statement to load this module, or include the module file directly



# --- CREATING POINTERS

obj.class myClass, is_myClass
# this gives the class namespace 'myClass' a few methods that we can use to manage pointers
# '.is_myClass' becomes a property that each object inherits to identify it as part of this class
# - lets make a 'myClass' object constructor to test it

.macro myClass.new, self, myProperty=0x100
# This constructor takes 'self' in as a name, and 'myProperty' as an optional initial property val

  myClass.obj \self
  # initialize object pointers using the '.obj' method
  # it will return 'def' and 'ndef' as true/false if object name is already defined, or not defined

  .if ndef
    \self = \myProperty
    # initialize an initial property, using given input
    # - if the caller gives no value to 'myProperty' then it will use '100' by default

  .endif
.endm
# This constructor will make objects for 'myClass'
# - they are simple objects with only a single property attribute

myClass.new x, 1
myClass.new y, 2
myClass.new z, 3
myClass.new q
myClass.new q, 4
# Create 4 new objects -- with 'q' using the default property value of '0x100'
# - redundantly attempting to define 'q' is ignored because of the '.if ndef' block in constructor

.long x, y, z, q
# >>> 1, 2, 3, 100
# - their properties can be invoked from the main object namespace 'self'

myValueCopy = q
.long myValueCopy
# >>> 100
# - assigning these to another symbol copies the property

q = 4
.long myValueCopy
# >>> 100
# - ... but doing this creates an entirely separate instance of the value
# - updates to q will not affect 'myValueCopy'

# Each object will create a special identifier value in the property given to 'obj.class'
# - in this case, '.is_myClass' is a property that we can check in x, y, z, and q
# - if we copy that instead of the value, then it's like saving the 'name' of the object

myPointer = q.is_myClass
# myPointer now holds the value associated with the object 'q' for 'myClass' pointers
# - the 'myClass.obj \self' line in the constructor is responsible for making this

myClass.point myPointer, .long
# >>> 4
# The class-level '.point' method can be used to pass a reference to 'q' from 'myPointer'
# - this is the same as typing out '.long q' -- but without explicitly naming 'q'
# - more on this in the 'USING POINTERS' section

# Another way of retrieving the pointer from an object is by using the class '.pointer' method

myClass.pointer z
# This generates a pointer in a return property of the same name as the method

myPointer = myClass.pointer
# This is the same as assigning 'z.is_myClass' directly to myPointer

.long myPointer
# >>> 3
# The pointer value is just a non-0 incrementing object counter ID
# - each object ID is unique only within the scope of the class 'myClass' namespace

myClass.pointer myPointer
.long myClass.pointer
# >>> 3
# If you give the .pointer method another symbol that isn't a 'myClass' object, it will copy it




# The 'get' argument of obj.class can be used to change the name of the '.pointer' attribute
# The 'dict' argument of obj.class can be used to change the name of the '.point' method



# --- USING POINTERS

x = 5
p = x.is_myClass
# 'p' is our new working pointer symbol; currently pointing to x

myClass.point p, .long 6
# >>> 5, 6
# Objects that are pointed to get passed to the front of a stack of comma-separated arguments
# - this is virtually '.long x, 6'

x = 9
myClass.pointq p, .long 7, 8
# >>> 7, 8, 9
# '.pointq' is a version of '.point' that 'queues' the args instead of stacking them
# - this is virtually '.long 7, 8, x'

x = 1
myClass.pointq "p, p+1, p+2", .long 0
# >>> 0, 1, 2, 3
# You may include several pointers as comma-separated values within a quoted string
# You may also use expressions to access indexed pointers as a contiguous array
# - this is virtually '.long x, y, z'
#   - the only reason 'y' and 'z' were captured is because they were instantiated in that order

.long p
# >>> 1
# 'x' is the first object we made, so it has the value of '1'

.long myClass$
# >>> 4
# 'myClass$' keeps track of how many pointers have been assigned
# 'x' 'y' 'z' and 'q' make 4 in total
# - it's possible to edit this to offset the generated pointer IDs
#   - up to 31 bits (no sign) may be used to create addresses


p = leet.is_myClass
# if you don't use the pointer -- you can pre-emptively assign it values that don't exist

backup = myClass$
myClass$ = 0x13370000
myClass.new leet, 5
# create a new object called 'leet' with a different virtual base address


# 'p' can now be safely used:

myClass.point "p", .long p
# >>> 5, 0x13370001
# "p" is the pointer to be handled, while '.long p' at the end just shows the pointer value
# - this separate address space can be treated like a virtual allocation for new pointers


myClass.point obj.point, .long p
# >>> 5, 0x13370001
# Alternatively, you can use 'obj.point', which is a volatile return property
# - this will record the last generated object pointer, until displaced by the next

leet = 6
myClass.point "0x13370001", .long 0x13370001
# >>> 6, 0x13370001
# - this is no different than the above example

myClass$ = backup
# restore generated ID back to original index

leet.property = 0x1337
.macro leet.method; .long leet.property; .endm
# example property and method attributes, for the 'leet' object

myClass.call_method p, .method
# >>> 0x1337
# - we can invoke the 'leet.method' method through the pointer 'p' using '.call_method'

myClass.get_property p, .property, x
.long x
# >>> 0x1337
# - we can get the 'leet.property' property through the pointer 'p' using '.get_property'

myClass.set_property p, .property, 1337
myClass.call_method p, .method
# >>> 1337 (0x539)
# - we can also set the 'leet.property' with '.set_property'

# With pointers and these pointer handlers, you can remotely access object attributes




# --- NULL POINTERS

# If a pointer isn't a positive (non-0) number, then it is considered 'null'
# - A negative number has the advantage of being able to 'disable' a pointer without destroying it
# - A 0 number has the ability to clear a pointer in a destructive way

leet.property = 0x13370000
p =  leet.is_myClass
n = -leet.is_myClass
b =  0
# Both 'p' and 'n' point to the 'leet' object, but 'n' is negative
# - 'b' is just a blank pointer, '0'

myClass.get_property p, .property, x
.long x
# >>> 0x13370000
# 'p' works as predicted

leet.property = 0x1337
myClass.get_property n, .property, x
.long x
# >>> 0x13370000
# ... but 'n' results in no operation -- the pointer is null, so nothing happens

myClass.get_property b, .property, x
.long x
# >>> 0x13370000
# ... a 0 also counts as null

n = -n
myClass.get_property n, .property, x
.long x
# >>> 0x1337
# By negating 'n', we turn it back into a positive number that retains the old pointer information






# --- SELF POINTER OBJECTS

obj.class.self_pointers = 1
# You may enable the 'self_pointers' option at the module level or the class level
# - here, we're doing it at the module level -- causing new classes to have it enabled too

obj.class int
# creating a new class of object called 'int'

.macro int, va:vararg
  .irp self, \va
    # This constructor creates any number of objects 'self' from one line of comma-separated args

    int.obj \self
    # create an object out of each argument object name

    .irp ppt, .value; \self\ppt = 0
      # we use the property '.value' to store a value for this int
      # - this is because 'self_pointers' causes the value of 'self' to become a pointer
      #   - this allows the object to be passed through symbol memory very easily
      #   - it also means however that it will require 'int' object handlers to make use of it

    .endr
  # (the second .irp block helps us avoid using '\()', which breaks in these circumstances)

  .endr
.endm

.macro int.long, va:vararg
  .irp self, \va
    .irp v, .value; .long \self\v; .endr
    # This simply emits a value from each given int object

  .endr
.endm


int a, b, c, d
# Create int objects a, b, c, and d

a.value = 1
b.value = 3
c.value = 3
d.value = 7
int.point "a, b, c, d", int.long
# >> 1, 3, 3, 7
# The handler 'int.long' will handle the inputs 'a, b, c, d'






# --- METHOD CONSTRUCTORS ---

# You can generate efficient mutator-driven methods for both classes and objects with '.meth'

auto.uses_mutators = 1
obj.class auto, isAuto
# create a new class called 'auto' with mutators enabled
# - this object class will automatically enable mutator methods for objects

.macro auto, self, arg=1
  \self = \arg
  auto.obj \self
  auto.meth \self, a, b, c
  # This will create object methods '.a', '.b', and '.c'

.endm # That's it!
# - objects made with this constructor will now connect to default class-level mutator modes
#   - we can define these below:

.macro auto.mut.a.default, self, i=1, va:vararg;  \self = \self + \i
# This macro defines the default behavior for 'a'

.endm; .macro auto.mut.b.default, self, i=1, va:vararg;  \self = \self - \i
.endm; .macro auto.mut.c.default, self, i=3, va:vararg;  \self = \self * \i
.endm; # Now objects generated for the 'auto' class will use these definitions by default

auto test
# create an object called 'test'
# - it has the default value of 1

test.a
.long test
# >>> 2
# We've invoked the '.a' method, which adds to the value by an argument (1 by default)

test.c
.long test
# >>> 6
# All of the methods are working as defined, even though they are not internal to the object


auto.meth, a, b, c
# This creates similar class-level methods, because the object name is blank
# - they connect to the very same macro definitions we made, above

auto.b test
.long test
# >>> 5
# We can invoke the routine that 'test.b' would use without actually using the object method

.purgem test.a
.purgem test.b
.purgem test.c
# This purges the object method. They can no longer be called, and the memory they used is free

auto.b test
.long test
# >>> 4
# ... however, we can still use these defined macros from the class-level methods!

test.mode a, shift
.macro auto.mut.a.shift, self, i=1, va:vararg;  \self = \self << \i; .endm
# This creates a hook object that causes the default behavior of 'test' to yield to a prefered mode

auto.a test
.long test
# >>> 8
# The hook object will influence class-level interactions with 'test' even though 'test.a' is purged

auto.purge_hook test, a
auto.a test
.long test
# >>> 9
# ... by purging the hook, we can restore the default behavior




# --- ANONYMOUS OBJECTS

# If you skip providing a name for the '.obj' method, a name is generated automatically
# - you will not know this name, but you can still reach the object via pointer

auto.obj
anon = obj.point
# 'anon' contains a copy of a pointer to our un-named object

auto.meth anon, a, b, c
auto.set_property anon,, 10
# - we can construct this anonymous object without directly referencing its name

auto.b anon
auto.get_property anon,, anon.property
.long anon.property
# >>> 9
# We copied a property from the anonymous object into 'anon.property' using the pointer in 'anon'




# --- HIDDEN PROPERTIES ---

# If you create a specialized constructor callback, you may make use of hidden object properties

myOtherClass.self_pointers = 1
obj.class myOtherClass, isMyOtherClass
# make a new class called 'myOtherClass' for creating an example constructor

.macro myOtherClass, self, default
  obj.hidden_constructor \self, myOtherClass.constructorCallback, \default
  # This method can be used to pass 'self' and any extra args over to a constructor handler
  # - the given callback will be given a special 'hidden namespace' arg in addition to 'self'

.endm


# When calling 'myOtherClass' to construct a new object, it will invoke '.constructorCallback' :

.macro myOtherClass.constructorCallback, hid, self, default
# This special constructor has its first argument dedicated to a hidden namespace, '\hid'
# - this namespace is difficult to type with normal ascii, making it hard to overwrite accidentally

  myOtherClass.obj \self
  # make an object called \self

  \hid\().ppt = \default
  # create a hidden property out of the \hid namespace

  .macro \self\().get, symbol
    \symbol = \hid\().ppt
    # this object method can be used to copy the hidden symbol

  .endm
  .macro \self\().set, value
    \hid\().ppt = \value
    # this object method can be used to assign a new value to the hidden symbol

  .endm
  .macro \self
    .long \hid\().ppt
    # this object method simply emits the current property value
  .endm

.endm


myOtherClass hider, 0x10
# Create an object called 'hider' and give it the default value of 10

hider
# >>> 10
# Calling the object by name will emit its value...

.long hider
# >>> 1
# ... but the value can't be gotten normally from the object like a symbol
# - the value of self is a pointer, in this case

hider.set 0x1337
hider
# >>> 1337
# The '.set' method we made writes to the hidden property...

hider.get myCopy
.long myCopy
# >>> 1337
# The '.get' method we made can copy the hidden property value to something else

# --- Example Results:

## 00000001 00000002
## 00000003 00000100
## 00000100 00000100
## 00000004 00000003
## 00000003 00000005
## 00000006 00000007
## 00000008 00000009
## 00000000 00000001
## 00000002 00000003
## 00000001 00000004
## 00000005 13370001
## 00000005 13370001
## 00000006 13370001
## 00001337 00001337
## 00000539 13370000
## 13370000 13370000
## 00001337 00000001
## 00000003 00000003
## 00000007 00000002
## 00000006 00000005
## 00000004 00000008
## 00000009 00000009
## 00000010 00000001
## 00001337 00001337
