# --- Scalar Index (Literal) Emitters
# A very basic set of altmacros that emit a literals that include an evaluated index value
# - indices are prefixed with a '$' symbol, to minimize intrusion in other namespaces
#   - '$' is used because it is the least useful of 3 valid non-alphanumeric chars in symbol names
#   - '$' stands for 'Scalar Index', and is used as the module's static namespace

# --- $.alt    <prefix>, i, <suffix>, ...
# - fastest user-level emitter method, but must be called in (and pass to) altmacro mode
#   - strings with spaces or problematic literals can be enclosed in brackets
#   - you may need to use a '!' prefix for to escape literal '<' '>' and '!' chars

# --- $.toalt  "<prefix>", i, "<suffix>", ...
# - like $, but can be called from noaltmacro mode
#   - bracket quotes must be enclosed in double qoutes, for compatibility

# --- $.noalt  "<prefix>", i, "<suffix>", ...
# - like $toalt, but passes to noaltmacro mode
#   - may be called from altmacro mode if strings do not have outer double quotes

# --- $.em and $.ema
# - these may be used to call the emitters directly using the '%' escape prefix on evaluations
#   - em emits in noaltmacro mode
#   - ema emits in altmacro mode, and assumes it is called in altmacro mode
# - using these directly requires a stricter input syntax, but may be faster than the other methods

# You may optionally append a 2, 3, or 4 to these method names to scale the number of args:
# --- $.alt2 p, i, s,  i2, s2,  ...
# --- $.alt3 p, i, s,  i2, s2,  i3, s3,  ...
# --- $.alt4 p, i, s,  i2, s2,  i3, s3,  i4, s4,  ...

/*## Examples:
myIndex=3
classID=4
objID=5
myClass$4.myObj$5 = 6
# noaltmacro mode...

$.toalt3 myNamespace, myIndex, "<=myClass>", classID, .myObj, objID
.long myNamespace$3
# now in altmacro mode...

$.alt3 myNamespace, myIndex, <=myClass>, classID, .myObj, objID
.long myNamespace$3
# still in altmacro mode...

$.noalt3 myNamespace, myIndex, <=myClass>, classID, .myObj, objID
.long myNamespace$3
# back to noaltmacro mode...

$.noalt3 myNamespace, myIndex, "<=myClass>", classID, .myObj, objID
.long myNamespace$3
##/*

# The '$' symbol char will be used in names to indicate a 'scalar index' value that follows it:
# --- myNamespace$1        - example of a scalar symbol name, using index '1'
# --- class.obj$1$44$20    - example of a format with 3 indices '1, 44, 20'

# If a trailing '$' doesn't have a numerical suffix, then it is a property of the whole index
#   space, rather than an individual index within the space.
# --- myNamespace$   - example of a property of the whole index space 'myNamespace'
# --- myNamespace$.i - example of another property of attribute of 'myNamespace'

.ifndef $.included; $.included = 0; .endif; .ifeq $.included; $.included = 1
.altmacro
.macro $.em,p,i,s,va:vararg;.noaltmacro;\p\()$\i\s\va
.endm;.macro $.ema,p,i,s,va:vararg;\p\()$\i\s\va
.endm;.macro $.alt,p,i,s,va:vararg;$.ema \p,%\i,\s,\va
.endm;.macro $.noalt,p,i,s,va:vararg;.altmacro;$.em \p,%\i,\s,\va
.endm;.macro $.toalt,p,i,s,va:vararg;.altmacro;$.ema \p,%\i,\s,\va
.endm;.macro $.em2,p,i,s,i2,s2,va:vararg;.noaltmacro;\p\()$\i\s\()$\i2\s2\va
.endm;.macro $.ema2,p,i,s,i2,s2,va:vararg;\p\()$\i\s\()$\i2\s2\va
.endm;.macro $.alt2,p,i,s,i2,s2,va:vararg;$.ema2 \p,%\i,\s,%\i2,\s2,\va
.endm;.macro $.noalt2,p,i,s,i2,s2,va:vararg;.altmacro;$.em2 \p,%\i,\s,%\i2,\s2,\va
.endm;.macro $.toalt2,p,i,s,i2,s2,va:vararg;.altmacro;$.ema2 \p,%\i,\s,%\i2,\s2,\va
.endm;.macro $.em3,p,i,s,i2,s2,i3,s3,va:vararg;.noaltmacro;\p\()$\i\s\()$\i2\s2\()$\i3\s3\va;
.endm;.macro $.ema3,p,i,s,i2,s2,i3,s3,va:vararg;\p\()$\i\s\()$\i2\s2\()$\i3\s3\va;
.endm;.macro $.alt3,p,i,s,i2,s2,i3,s3,va:vararg
  $.ema3 \p,%\i,\s,%\i2,\s2,%\i3,\s3 \va
.endm;.macro $.noalt3,p,i,s,i2,s2,i3,s3,va:vararg
  .altmacro;$.em3 \p,%\i,\s,%\i2,\s2,%\i3,\s3 \va
.endm;.macro $.toalt3,p,i,s,i2,s2,i3,s3,va:vararg
  .altmacro;$.ema3 \p,%\i,\s,%\i2,\s2,%\i3,\s3 \va
.endm;.macro $.em4,p,i,s,i2,s2,i3,s3,i4,s4,va:vararg;
  .noaltmacro;\p\()$\i\s\()$\i2\s2\()$\i3\s3\()$\i4\s4\va;
.endm;.macro $.ema4,p,i,s,i2,s2,i3,s3,i4,s4,va:vararg;
  \p\()$\i\s\()$\i2\s2\()$\i3\s3\()$\i4\s4\va;
.endm;.macro $.alt4,p,i,s,i2,s2,i3,s3,va:vararg
  $.ema4 \p,%\i,\s,%\i2,\s2,%\i3,\s3,%\i4,\s4,\va
.endm;.macro $.noalt4,p,i,s,i2,s2,i3,s3,va:vararg
  .altmacro;$.em4 \p,%\i,\s,%\i2,\s2,%\i3,\s3,%\i4,\s4,\va
.endm;.macro $.toalt4,p,i,s,i2,s2,i3,s3,va:vararg
  .altmacro;$.ema4 \p,%\i,\s,%\i2,\s2,%\i3,\s3,%\i4,\s4,\va
.endm # methods for emitting up to 4 evaluated index args
.noaltmacro
.endif
/**/
