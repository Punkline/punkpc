# --- Scalar Index Tools
#>toc obj : integer buffers
# - useful for referencing object/dictionary elements as part of an array of indexed symbols
#   - symbol arrays are indexed literally by casting evaluated indices into decimal literals
#   - the decimal literals are appended to symbol names with a `$` delimitter
#     - '$' stands for 'Scalar Index'

# --- Updates:
# version 0.0.4
# - added '.rept' method, from old 'stack' module
# version 0.0.3
# - added get/set methods
# version 0.0.2
# - refactored namespace to match module name
# version 0.0.1
# - added to punkpc module library

# The '$' symbol char will be used in names to indicate a 'scalar index' value that follows it:
# --- myNamespace$1        - example of a scalar symbol name, using index '1'
# --- class.obj$1$44$20    - example of a format with 3 indices '1, 44, 20'

# If a trailing '$' doesn't have a numerical suffix, then it is a property of the whole index
#   space, rather than an individual index within the space.
# --- myNamespace$   - example of a property of the whole index space 'myNamespace'
# --- myNamespacesidx.i - example of another property of attribute of 'myNamespace'





# --- Class Property

# --- sidx - an input/output buffer for getting and setting values to an indexed scalar symbol




# --- Class Methods

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
# --- sidx.alt2   p, i, s,  i2, s2,  ...
# --- sidx.alt3   p, i, s,  i2, s2,  i3, s3,  ...
# --- sidx.alt4   p, i, s,  i2, s2,  i3, s3,  i4, s4,  ...

# --- sidx.get    p, i
# - use this to quickly save the value of a target scalar index symbol to the 'sidx' property

# --- sidx.set    p, i
# - use this to quickly write the value of the 'sidx' property to a target scalar index symbol

# You may alos optionally append a 2, 3, or 4 to these get/set method names;
# --- sidx.get2   p, i, i2
# --- sidx.get3   p, i, i2, i3
# --- sidx.get4   p, i, i2, i3, i4
# --- sidx.set2   p, i, i2
# --- sidx.set3   p, i, i2, i3
# --- sidx.set4   p, i, i2, i3, i4
# - use 'sidx' property to input/output values from various scalar symbols this way

# --- sidx.rept   p, start, end, macro, ...
# A loop dispatcher that passes p$i, for sequence start...end
# - 'macro' is the name of a macro, instruction, or directive that handles the outputs
# - '...' may contain any args that come after the output
# - if start and/or end are blank, they will be set to '0'.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module sidx, 4
.if module.included == 0
punkpc ifalt

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

.macro sidx.get,p,i; .altmacro; sidx.ema <sidx=\p>, %\i;
  .noaltmacro; .endm
.macro sidx.get2,p,i,i2; .altmacro; sidx.ema2 <sidx=\p>, %\i,,%\i2;
  .noaltmacro; .endm
.macro sidx.get3,p,i,i2,i3; .altmacro; sidx.ema3 <sidx=\p>, %\i,,%\i2,,%\i3;
  .noaltmacro; .endm
.macro sidx.get4,p,i,i2,i3,i4; .altmacro; sidx.ema4 <sidx=\p>, %\i,,%\i2,,%\i3,,%\i4;
  .noaltmacro; .endm
.macro sidx.set,p,i; .altmacro; sidx.ema \p, %\i,<=sidx>;
  .noaltmacro; .endm
.macro sidx.set2,p,i,i2; .altmacro; sidx.ema2 \p, %\i,,%\i2,<=sidx>;
  .noaltmacro; .endm
.macro sidx.set3,p,i,i2,i3; .altmacro; sidx.ema3 \p, %\i,,%\i2,,%\i3,<=sidx>;
  .noaltmacro; .endm
.macro sidx.set4,p,i,i2,i3,i4; .altmacro; sidx.ema4 \p, %\i,,%\i2,,%\i3,,%\i4,<=sidx>;
  .noaltmacro; .endm

  .noaltmacro

.macro sidx.rept, self, va:vararg
  sidx.memalt = alt; ifalt
  sidx.alt = alt
  sidx.__rept \self, +1, \va
.endm; .macro sidx.__rept, self, step, start=0, end=0, macro, va:vararg
  .if (\step > 0) && (\start > \end); sidx.__rept \self, -1, \start, \end, "\macro", \va
  .else; sidx.__rept = \start
    sidx.__rept_count = (\end+1) - \start
    .if sidx.__rept_count < 0; sidx.__rept_count = -sidx.__rept_count +2; .endif
    .if sidx.__rept_count
      .rept sidx.__rept_count;
        .ifb \va; sidx.noalt "<sidx.__rept_iter \macro, \self>", sidx.__rept
        .else; sidx.noalt "<sidx.__rept_iter \macro, \self>", sidx.__rept,,,\va; .endif
        sidx.__rept = sidx.__rept + \step
      .endr; ifalt.reset sidx.alt; alt = sidx.memalt
    .endif
  .endif
.endm; .macro sidx.__rept_iter, macro, mem, va:vararg
  ifalt.reset sidx.alt; \macro \mem \va
.endm

.endif
/**/
