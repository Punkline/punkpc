# --- If Symbol is Defined
#>toc if
# - an if tool that circumvents the need for `\` chars in .ifdef checks
#   - this is needed to prevent errors when testing argument names in macro definitions
# - used to provide most protections for object and class namespaces

# --- Example use of the ifdef module:

.include "punkpc.s"
punkpc ifdef
# - load the 'ifdef' module in this example so that we can use its global method 'ifdef'

# Below is an example of how to make a simple class/object module using macros and symbol
# - the ifdef module will be required to do this smoothly

# This module will create a simple object class called 'myClass'
# - you may harmlessly include this example module multiple times
# - it will only be installed once, within the .ifeq module block below
#   - this makes it possible to safely follow dependency trees from other modules that do the same

.ifndef myClass.included
  # if this is the first time this module has been included, this symbol will not yet exist
  # this statement has no '\' in it, so it's safe for a regular '.ifdef' or '.ifndef' directive

  myClass.included = 0
  # default global version number = null
  # - this sets up the module to safely install on its first run

.endif;

# Now, we are absolutely sure that the symbol 'myClass.included' at the very least EXISTS
# if it is 0 however, then it needs to be initialized


.ifeq myClass.included
# check to see if the variable is still null
# - if it isn't null, then another version was installed by some other inclusion of this module

# if null, then install the module:
  myClass.included = 1
  # The version must be set to a non-0 number when installed
  # you may optionally modify the version to reflect any updates made to a module
  # - this may be useful for distinguishing nuanced version differences, for compatibility reasons
  # - regardless of number; the quality of not being zero signifies that it is installed


  # At this point in the .ifeq block...
  # We are committed to initializing the class module, so we need to create the constructor.

  # First we make an instance counter:
  myClass$ = 0
  # this counter is used to assign unique IDs to each object generated from the 'myClass' class
  # - these can be fashioned into pointers, with some extra work
  # - I use '$' suffixes to denote a 'scalar index' -- but that's just a personal habit


  # Macros inside of a module can be thought of as class methods if they use a common namespace
  # - they will only be installed once because of the myClass.included symbol

  # Each object of this 'myClass' class will have a unique name with its own methods and properties

  .macro myClass, self, ppt=0, cb="emit_string"
    # This object constructor will create a 'myClass' class of object. An instance of 'myClass'.
    # if the object already exists by the given name 'self', then its attributes are updated
    # - 'self' will become the name of the newly instantiated object

    # like the module block, we have to use .ifdef to check if self exists
    # --- The problem here is that the escaped, terminated name is '\self\()'
    # - this contains '\' chars, and can't be checked by .ifdef without creating errors

    ifdef \self\().is_myClass
    # --- Calling ifdef will update the global 'def' and 'ndef' properties
    # - you can check these like bools with regular .if statements, to avoid using .ifdef or .ifndef
    # - macro will always return in .noaltmacro mode

    .if ndef;
    # By using 'ndef' with a regular '.if' directive...
    #  we can check to see if \self\().is_myClass exists, and not invoke errors from the '\'
    # - .is_myClass property identifies this namespace as belonging to 'myClass'


      myClass$ = myClass$ + 1
      \self\().is_myClass = myClass$
      # Use the instance counter to assign a unique ID to '.is_myClass' -- to identify the object by

    .elseif def;
    # else, if the object already exists and is a member of 'myClass'...

      .purgem \self
      .purgem \self\().myMethod
      # ... then just purge the method attributes so that we can redefine them with new arguments

    .endif


    # At this point, the object is ready to be defined -- regardless if it's new or old
    # - for this example, we'll make an object that memorizes a value and emits it using a callback

    \self = \ppt
    # The constructor will create a main object property out of the given 'ppt' argument
    # - this property can be read or written to, but it will start out with the value of '\ppt'


    # Now the constructor will build a method for this object...

    .macro \self
      # main method will recall the '\cb' argument that it was built with
      # - 'cb' is a 'callback' -- where the name is used to invoke a macro
      # - 'self' passes the name of this object to the macro so that its main property can be used
      \cb \self

      # This will cause the main property of this object to be invoked by whatever callback is given

    .endm
    .macro \self\().myMethod, prpt=\ppt, cbk="\cb"
      # .myMethod will reconstruct itself with new argument attributes
      # - if an arg is blank, it will default to old arguments given by constructor

      myClass \self, \prpt, \cbk
      # calling class constructor with own name will reset attributes

    .endm;  # end of last object method
  .endm;  # end of constructor method
.endif;  # end of module block


# this example module is now safe to import using .include "./path/file.ext"
# - without 'ifdef' the process of naming objects would be more of a headache



# Here are some callback functions to test the above module with:
.macro emit_word, i;  .long \i;  .endm
.macro emit_4byte, i;  .rept 4; .byte \i; .endr; .endm
.macro emit_string, str;  .ascii "\str";  .endm

myClass myObj, 1, emit_word
# create a new 'myClass' object called 'myObj'
# - it has a value of 1, and emits it as a word when called

myClass otherObj, myObj, emit_4byte
# create a second object out of the main property value of the first object
# - it evaluates myObj's main property and copies its value, emitting it as 4 repeated bytes

myObj
# >>> 00000001
# 'myObj' remembers its value and function (as a property and a method name)

otherObj
# >>> 01 01 01 01
# 'otherObj' copied the value from myObj, but uses a different method

myObj.myMethod 2
# change the value of myObj with the '.myMethod' object method

myObj; otherObj
# >>> 00000002  01 01 01 01
# - otherObj retains memory of previous evaluation of myObj, on construction

otherObj.myMethod
# by invoking previously given args on construction, we can update otherObj with another copy

myObj; otherObj
# >>> 00000002 02 02 02 02
# otherObj has copied myObj again, from invoking default attribute reassignment in '.myMethod'

myObj.myMethod 1, emit_string
myObj
# >>> 6D794F62 6A
# >>> "myObj"
# attempting to retrieve the value as a string will return the literal property name, instead


# --- IFDEF CONCATENATION

# It's also possible to pass multiple arguments and have ifdef concatenate them for you
# - this can be used to bypass issues with handling literals that normally require use of '\()'
.macro tester, self
  .irp x, count, length, x, y
  # this loop will check for the properties 'count, length, x, y' in 'self'

    ifdef \self, ., \x
    # Checks \self\().\x  without using '\()' -- another problematic case for vanilla '.ifdef'

    .long def_value
    # the 'def_value' property returns the value of a detected symbol with 'ifdef'

  .endr
.endm

.align 2
myTest.x = 0x100
myTest.y = 0x180
tester myTest
# >>> 0, 0, 100, 180
# The 'tester' macro detects that only the .x and .y properties exist
# - the 'def_value' property returns the value of the concatenated symbol name, if detected
#   - in cases were no symbol was detected, the value becomes 0

# --- Example Results:

## 00000001 01010101
## 00000002 01010101
## 00000002 02020202
## 6D794F62 6A000000
## 00000000 00000000
## 00000100 00000180
