.include "./punkpc/str.s"    # strings module - for creating iterabators
.include "./punkpc/ifdef.s"  # ifdef module  - for checking if an escaped symbol name exists
.include "./punkpc/dbg.s"    # dbg module  - for displaying errors that show evaluations


.macro dict, self, varg:vararg
# This macro constructs simplified dictionaries

  .ifnb \self  # for each non-blank dictionary name...

    ifdef \self
    .if ndef # if this hasn't been defined yet...

    # ... then define the 2 following methods:


      .macro \self\().update, kw, val=0, va:vararg
        \self\()$\kw = \val # assign value ...
        .if \self\().keywords.count # if keywords are in dictionary...
          \self\().keywords.conc ", \kw"
        .else  # then concat a new keyword name to list
          \self\().keywords.conc "\kw"
        .endif  # else create first keyword name in list

        \self\().keywords.count = \self\().keywords.count + 1  # increment counter
        .ifnb \va; \self\().update \va; .endif # then recurse ...

      .endm # This updates a dictionary namespace by assigning kw:val elements

      .macro \self\().test, kw
        ifdef \self\()$\kw
        .if def  # check a name containing '\' through the ifdef macro, and the return 'def' value
          .error "\self contains the keyword \042\kw\042"; dbg \self\()$\kw
        .else; .error "\042\kw\042 was not found in \self"; .endif
      .endm # This demonstrates a check for keywords existing in a dictionary

      .macro \self\().irp, cb, va:vararg
        str dict.irp ".irp kw"
        # 'dict.irp' string builds a loop that uses 'kw' to escape each keyword in the dictionary

        \self\().keywords.litq, dict.irp.conc  # keywords are dumped from dict object's string
        dict.irp.conc "; \cb \self\()$\kw \va; .endr"  # argument callback line is added in body
        dict.irp.lit  # self-contained .irp loop block is emitted as a string of literals
      .endm  # This demonstrates an iterable list of keyword references from the dictionary object


    # ... and then create a string to hold a list of keywords:

      str \self\().keywords
      \self\().keywords.count = 0
    # end of dictionary definition

    # ... finally, recurse to check for more definitions
      dict \varg
    .endif
  .endif

.endm; .macro dict.test_compare, kw, a, b
  .if \a\()$\kw == \b\()$\kw
    .error "\a and \b have the same \042\kw\042 value"
  .else
    .error "\a and \b have differing \042\kw\042 values"
  .endif
.endm  # This demonstrates a comparison of 2 like-named values from different dictionaries

.macro dict.test_iter, d
  \d\().irp "dbg"  # test iterator makes a dbg call for each keyword -- showing each evaluation
.endm

# --- end of macro definitions

dict x, y  # create dictionaries x and y

myVar = 100  # this is just an example of a normal variable that we can use as a value

x.update "Red",0xD41A26FF, "Blue",0x4249A2FF,   "Pi",0x40490FDB
y.update "Red",0xFF0000FF, "TestKeyword",myVar, "Pi",0x40490FDB
# Define some initial dictionary entries

x.test "TestKeyword"
# >>> Error: "TestKeyword" was not found in x

y.test "TestKeyword"
# >>> Error: y contains the keyword "TestKeyword"
# >>> Error: y$TestKeyword = 100

dict.test_compare "Red", x, y
# >>> Error: x and y have differing "Red" values

dict.test_compare "Pi", x, y
# >>> Error: x and y have the same "Pi" value

dict.test_iter x
dict.test_iter y
# >>> Error: x$Red = -736483585
# >>> Error: x$Blue = 1112122111
# >>> Error: x$Pi = 1078530011
# >>> Error: y$Red = -16776961
# >>> Error: y$TestKeyword = 100
# >>> Error: y$Pi = 1078530011
