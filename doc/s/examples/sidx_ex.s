# --- Scalar Index Tools
#>toc obj : integer buffers
# - useful for referencing object/dictionary elements as part of an array of indexed symbols
#   - symbol arrays are indexed literally by casting evaluated indices into decimal literals
#   - the decimal literals are appended to symbol names with a `$` delimitter
#     - '$' stands for 'Scalar Index'

# --- Example use of the sidx module:

.include "punkpc.s"
punkpc sidx
# Use the 'punkpc' statement to load this module, or include the module file directly



# --- MULTIDIMENSIONAL SCALAR INDICES ---

myIndex=3
classID=4
objID=5
myClass$4.myObj$5 = 6
# noaltmacro mode...

sidx.toalt3 myNamespace, myIndex, "<=myClass>", classID, .myObj, objID
.long myNamespace$3
# >>> 00000006
# now in altmacro mode...

sidx.alt3 myNamespace, myIndex, <=myClass>, classID, .myObj, objID
.long myNamespace$3
# >>> 00000006
# still in altmacro mode...

sidx.noalt3 myNamespace, myIndex, <=myClass>, classID, .myObj, objID
.long myNamespace$3
# >>> 00000006
# back to noaltmacro mode...

sidx.noalt3 myNamespace, myIndex, "<=myClass>", classID, .myObj, objID
.long myNamespace$3
# >>> 00000006




# --- GET AND SET ---
# You can also use a simpler I/O interface in noaltmacro mode using the .get and .set methods:

idx = 1000
sidx = 5
# sidx is our input parameter, idx is the index we want to assign it to

sidx.set mykeys, idx
.long mykeys$1000
# >>> 00000005

sidx = 0
# clear sidx property to demonstrate return update from .get ...

sidx.get mykeys, idx
.long sidx
# >>> 00000005
# sidx property has been updated from .get

sidx.set4 mykeys, idx, idx, idx, idx
.long mykeys$1000$1000$1000$1000
# >>> 00000005
# example of a complex index




# --- REPT ---

a$1 = 100
a$2 = 101
a$3 = 102
a$4 = 103
# set some values in a sequence of indices

sidx.rept a, 1, 4, .long
# >>> 100, 101, 102, 103
# The sequence of values in range 1 ... 4 are passed to the '.byte' directive
# - this is done one item at a time
#   - the macro or directive recieves the literals 'a$1', 'a$2', etc

sidx.rept a, 4, 1, .long
# >>> 103, 102, 101, 100
# If the indices are reversed, then they will be passed in descending order instead of ascending

# --- Example Results:

## 00000006 00000006
## 00000006 00000006
## 00000005 00000005
## 00000005 00000064
## 00000065 00000066
## 00000067 00000067
## 00000066 00000065
## 00000064
