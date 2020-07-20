# --- ifdef - alternative to .ifdef that prevents errors caused by '\' in .ifdef statements
# - a bug in the .ifdef directive causes '\' to be uninterpretable when trying to escape arguments
# - ifdef provides a safer alternative


# --- Example use of the ifdef module:

.include "./punkpc/ifdef.s"
# - load the 'ifdef' module in this example so that we can use its global method 'ifdef'

# Below is an example of how to make a simple class/object module using macros and symbol
# - the ifdef module will be required to do this smoothly

# This module will create a simple object class called 'myClass'
# - you may harmlessly include this example module multiple times
# - it will only be installed once, within the .ifeq module block below
#   - this makes it possible to safely follow dependency trees from other modules that do the same

.ifndef myClass.included
  # if this is the first time this module has been included, this symbol will not yet exist
  # this statement has no '\' in it, so it's safe for a regular '.ifdef' directive

  myClass.included = 0
  # default global version number = null
  # - this sets up the module to safely install on its first run

.endif;

.ifeq myClass.included
# check to see if the variable is still null
# if null, then install the module:
# - if it isn't null, then another version was installed by some other inclusion of this module

  myClass.included = 1
  # The version must be set to a non-0 number when installed
  # you may optionally modify the version to reflect updates to a module
  # - this may be useful for distinguishing nuanced version differences, for compatibility reasons
  # - regardless of number; the quality of not being zero signifies an installed module

  myClass$ = 0
  # an index counter is used to assign unique IDs to each object generated from the 'myClass' class
  # - these can be fashioned into pointers, with some extra work
  # - I use '$' suffixes to denote list index symbols -- but it can be called anything


  # Macros inside of a module can be thought of as class methods if they use a common namespace
  # - they will only be installed once, with the module

  # Each object of this 'myClass' class will have a unique name with its own methods and properties

  .macro myClass, self, ppt=0, cb="emit_string"
    # This object constructor will create a 'myClass' object instance
    # if the object already exists by the given name 'self', then its attributes are updated
    # - the object will be given the name given as the 'self' argument

    # like the module block, we have to use .ifdef to check if self exists
    # --- The problem here is that the escaped, terminated name is '\self\()'
    # - this contains '\' chars, and can't be checked by .ifdef without creating errors

    ifdef \self\().ismyClass
    # --- Calling ifdef will update the 'def' and 'ndef' bools
    # --- It will always return in .noaltmacro mode

    .if ndef;
      myClass$ = myClass$ + 1
      \self\().ismyClass = myClass$
      # if self isn't a myClass yet, then generate an ID for it
      # - this check comes from the update 'ndef' property, which was assigned by 'ifdef'

    .elseif def;
      .purgem \self
      .purgem \self\().myMethod
      # if self IS a myClass already, then purge the methods we created for it last time

    .endif;

    \self = \ppt
    # assign property of self to constructor argument 'ppt'

    .macro \self
      # main method will recall attribute memory it was built with
      \cb \self

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
# create a new object out of the main property value of 'myObj'
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


# --- Module attributes:
# --- Class Properties ----------------------------------------------------------------------------

# --- def  - bool is True if given name has been defined
# --- ndef - not def -- inverse of def
# these globals can be used as evaluable properties in .if statements


# --- ifdef  name
# Checks if name exists by passing it to altmacro mode, and resetting back to noaltmacro mode
# name : a name that contains '\'
# - altmacro mode does not require '\' when escaping arguments
#   - the parsing bug is bypassed by reading the name as an argument and escaping it internally

