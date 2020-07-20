/*## Header:
# --- Scalar Index (Literal) Emitters
# A very basic set of altmacros that emit literals that include an evaluated index value
# - indices are prefixed with a '$' symbol, to minimize intrusion in other namespaces
#   - '$' is used because it is the least useful of 3 valid non-alphanumeric chars in symbol names
#   - '$' stands for 'Scalar Index'

# The '$' symbol char will be used in names to indicate a 'scalar index' value that follows it:
# --- myNamespace$1        - example of a scalar symbol name, using index '1'
# --- class.obj$1$44$20    - example of a format with 3 indices '1, 44, 20'

# If a trailing '$' doesn't have a numerical suffix, then it is a property of the whole index
#   space, rather than an individual index within the space.
# --- myNamespace$   - example of a property of the whole index space 'myNamespace'
# --- myNamespacesidx.i - example of another property of attribute of 'myNamespace'

##*/
/*## Attributes:
# --- Class Methods ---

# --- sidx.alt    <prefix>, i, <suffix>, ...
# - fastest user-level emitter method, but must be called in (and pass to) altmacro mode
#   - strings with spaces or problematic literals can be enclosed in brackets
#   - you may need to use a '!' prefix for to escape literal '<' '>' and '!' chars

# --- sidx.toalt  "<prefix>", i, "<suffix>", ...
# - like $noalt, but can be called from noaltmacro mode
#   - bracket quotes must be enclosed in double qoutes, for compatibility

# --- sidx.noalt  "<prefix>", i, "<suffix>", ...
# - like $toalt, but passes to noaltmacro mode
#   - may be called from altmacro mode if strings do not have outer double quotes

# --- sidx.em and sidx.ema
# - these may be used to call the emitters directly using the '%' escape prefix on evaluations
#   - em emits in noaltmacro mode
#   - ema emits in altmacro mode, and assumes it is called in altmacro mode
# - using these directly requires a stricter input syntax, but may be faster than the other methods

# You may optionally append a 2, 3, or 4 to these method names to scale the number of args:
# --- sidx.alt2 p, i, s,  i2, s2,  ...
# --- sidx.alt3 p, i, s,  i2, s2,  i3, s3,  ...
# --- sidx.alt4 p, i, s,  i2, s2,  i3, s3,  i4, s4,  ...

##*/
/*## Examples:
.include "./punkpc/sidx.s"

myIndex=3
classID=4
objID=5
myClass$4.myObj$5 = 6
# noaltmacro mode...

sidx.toalt3 myNamespace, myIndex, "<=myClass>", classID, .myObj, objID
.long myNamespace$3
# now in altmacro mode...

sidx.alt3 myNamespace, myIndex, <=myClass>, classID, .myObj, objID
.long myNamespace$3
# still in altmacro mode...

sidx.noalt3 myNamespace, myIndex, <=myClass>, classID, .myObj, objID
.long myNamespace$3
# back to noaltmacro mode...

sidx.noalt3 myNamespace, myIndex, "<=myClass>", classID, .myObj, objID
.long myNamespace$3

##*/

.ifndef sidx.included; sidx.included = 0; .endif; .ifeq sidx.included; sidx.included = 2
# version 0.0.2:
# - refactored namespace to match module name

.altmacro
.macro sidx.em,p,i,s,va:vararg;.noaltmacro;\p\()$\i\s\va
.endm;.macro sidx.ema,p,i,s,va:vararg;\p\()$\i\s\va
.endm;.macro sidx.alt,p,i,s,va:vararg;sidx.ema \p,%\i,\s,\va
.endm;.macro sidx.noalt,p,i,s,va:vararg;.altmacro;sidx.em \p,%\i,\s,\va
.endm;.macro sidx.toalt,p,i,s,va:vararg;.altmacro;sidx.ema \p,%\i,\s,\va
.endm;.macro sidx.em2,p,i,s,i2,s2,va:vararg;.noaltmacro;\p\()$\i\s\()$\i2\s2\va
.endm;.macro sidx.ema2,p,i,s,i2,s2,va:vararg;\p\()$\i\s\()$\i2\s2\va
.endm;.macro sidx.alt2,p,i,s,i2,s2,va:vararg;sidx.ema2 \p,%\i,\s,%\i2,\s2,\va
.endm;.macro sidx.noalt2,p,i,s,i2,s2,va:vararg;.altmacro;sidx.em2 \p,%\i,\s,%\i2,\s2,\va
.endm;.macro sidx.toalt2,p,i,s,i2,s2,va:vararg;.altmacro;sidx.ema2 \p,%\i,\s,%\i2,\s2,\va
.endm;.macro sidx.em3,p,i,s,i2,s2,i3,s3,va:vararg;.noaltmacro;\p\()$\i\s\()$\i2\s2\()$\i3\s3\va;
.endm;.macro sidx.ema3,p,i,s,i2,s2,i3,s3,va:vararg;\p\()$\i\s\()$\i2\s2\()$\i3\s3\va;
.endm;.macro sidx.alt3,p,i,s,i2,s2,i3,s3,va:vararg
  sidx.ema3 \p,%\i,\s,%\i2,\s2,%\i3,\s3 \va
.endm;.macro sidx.noalt3,p,i,s,i2,s2,i3,s3,va:vararg
  .altmacro;sidx.em3 \p,%\i,\s,%\i2,\s2,%\i3,\s3 \va
.endm;.macro sidx.toalt3,p,i,s,i2,s2,i3,s3,va:vararg
  .altmacro;sidx.ema3 \p,%\i,\s,%\i2,\s2,%\i3,\s3 \va
.endm;.macro sidx.em4,p,i,s,i2,s2,i3,s3,i4,s4,va:vararg;
  .noaltmacro;\p\()$\i\s\()$\i2\s2\()$\i3\s3\()$\i4\s4\va;
.endm;.macro sidx.ema4,p,i,s,i2,s2,i3,s3,i4,s4,va:vararg;
  \p\()$\i\s\()$\i2\s2\()$\i3\s3\()$\i4\s4\va;
.endm;.macro sidx.alt4,p,i,s,i2,s2,i3,s3,va:vararg
  sidx.ema4 \p,%\i,\s,%\i2,\s2,%\i3,\s3,%\i4,\s4,\va
.endm;.macro sidx.noalt4,p,i,s,i2,s2,i3,s3,va:vararg
  .altmacro;sidx.em4 \p,%\i,\s,%\i2,\s2,%\i3,\s3,%\i4,\s4,\va
.endm;.macro sidx.toalt4,p,i,s,i2,s2,i3,s3,va:vararg
  .altmacro;sidx.ema4 \p,%\i,\s,%\i2,\s2,%\i3,\s3,%\i4,\s4,\va
.endm # methods for emitting up to 4 evaluated index args
.noaltmacro
.endif
/**/
