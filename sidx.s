.ifndef $.included; $.included = 0; .endif; .ifeq $.included; $.included = 1; .altmacro
.macro $.em,p,i,s,va:vararg;.noaltmacro;\p\()$\i\s\va; .endm
.macro $.ema,p,i,s,va:vararg;\p\()$\i\s\va; .endm;.macro $.alt,p,i,s,va:vararg;$.ema \p,%\i,\s,\va
.endm;.macro $.noalt,p,i,s,va:vararg;.altmacro;$.em \p,%\i,\s,\va; .endm
.macro $.toalt,p,i,s,va:vararg;.altmacro;$.ema \p,%\i,\s,\va; .endm
.macro $.em2,p,i,s,i2,s2,va:vararg;.noaltmacro;\p\()$\i\s\()$\i2\s2\va; .endm
.macro $.ema2,p,i,s,i2,s2,va:vararg;\p\()$\i\s\()$\i2\s2\va; .endm
.macro $.alt2,p,i,s,i2,s2,va:vararg;$.ema2 \p,%\i,\s,%\i2,\s2,\va; .endm
.macro $.noalt2,p,i,s,i2,s2,va:vararg;.altmacro;$.em2 \p,%\i,\s,%\i2,\s2,\va; .endm
.macro $.toalt2,p,i,s,i2,s2,va:vararg;.altmacro;$.ema2 \p,%\i,\s,%\i2,\s2,\va; .endm
.macro $.em3,p,i,s,i2,s2,i3,s3,va:vararg;.noaltmacro;\p\()$\i\s\()$\i2\s2\()$\i3\s3\va
.endm;.macro $.ema3,p,i,s,i2,s2,i3,s3,va:vararg;\p\()$\i\s\()$\i2\s2\()$\i3\s3\va; .endm
.macro $.alt3,p,i,s,i2,s2,i3,s3,va:vararg; $.ema3 \p,%\i,\s,%\i2,\s2,%\i3,\s3 \va; .endm
.macro $.noalt3,p,i,s,i2,s2,i3,s3,va:vararg; .altmacro;$.em3 \p,%\i,\s,%\i2,\s2,%\i3,\s3 \va
.endm;.macro $.toalt3,p,i,s,i2,s2,i3,s3,va:vararg; .altmacro
$.ema3 \p,%\i,\s,%\i2,\s2,%\i3,\s3 \va; .endm;.macro $.em4,p,i,s,i2,s2,i3,s3,i4,s4,va:vararg
.noaltmacro;\p\()$\i\s\()$\i2\s2\()$\i3\s3\()$\i4\s4\va; .endm
.macro $.ema4,p,i,s,i2,s2,i3,s3,i4,s4,va:vararg; \p\()$\i\s\()$\i2\s2\()$\i3\s3\()$\i4\s4\va
.endm;.macro $.alt4,p,i,s,i2,s2,i3,s3,va:vararg; $.ema4 \p,%\i,\s,%\i2,\s2,%\i3,\s3,%\i4,\s4,\va
.endm;.macro $.noalt4,p,i,s,i2,s2,i3,s3,va:vararg; .altmacro
$.em4 \p,%\i,\s,%\i2,\s2,%\i3,\s3,%\i4,\s4,\va; .endm;.macro $.toalt4,p,i,s,i2,s2,i3,s3,va:vararg
.altmacro;$.ema4 \p,%\i,\s,%\i2,\s2,%\i3,\s3,%\i4,\s4,\va; .endm; .noaltmacro; .endif
