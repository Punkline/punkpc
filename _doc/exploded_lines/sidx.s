.ifndef sidx.included
  sidx.included = 0
.endif;
.ifeq sidx.included
  sidx.included = 2
  .altmacro
  .macro sidx.em,  p,  i,  s,  va:vararg
    .noaltmacro
    \p\()$\i\s\va
  .endm;
  .macro sidx.ema,  p,  i,  s,  va:vararg
    \p\()$\i\s\va
  .endm;
  .macro sidx.alt,  p,  i,  s,  va:vararg
    sidx.ema \p, %\i, \s, \va
  .endm;
  .macro sidx.noalt,  p,  i,  s,  va:vararg
    .altmacro
    sidx.em \p, %\i, \s, \va
  .endm;
  .macro sidx.toalt,  p,  i,  s,  va:vararg
    .altmacro
    sidx.ema \p, %\i, \s, \va
  .endm;
  .macro sidx.em2,  p,  i,  s,  i2,  s2,  va:vararg
    .noaltmacro
    \p\()$\i\s\()$\i2\s2\va
  .endm;
  .macro sidx.ema2,  p,  i,  s,  i2,  s2,  va:vararg
    \p\()$\i\s\()$\i2\s2\va
  .endm;
  .macro sidx.alt2,  p,  i,  s,  i2,  s2,  va:vararg
    sidx.ema2 \p, %\i, \s, %\i2, \s2, \va
  .endm;
  .macro sidx.noalt2,  p,  i,  s,  i2,  s2,  va:vararg
    .altmacro
    sidx.em2 \p, %\i, \s, %\i2, \s2, \va
  .endm;
  .macro sidx.toalt2,  p,  i,  s,  i2,  s2,  va:vararg
    .altmacro
    sidx.ema2 \p, %\i, \s, %\i2, \s2, \va
  .endm;
  .macro sidx.em3,  p,  i,  s,  i2,  s2,  i3,  s3,  va:vararg
    .noaltmacro
    \p\()$\i\s\()$\i2\s2\()$\i3\s3\va
  .endm;
  .macro sidx.ema3,  p,  i,  s,  i2,  s2,  i3,  s3,  va:vararg
    \p\()$\i\s\()$\i2\s2\()$\i3\s3\va
  .endm;
  .macro sidx.alt3,  p,  i,  s,  i2,  s2,  i3,  s3,  va:vararg
    sidx.ema3 \p, %\i, \s, %\i2, \s2, %\i3, \s3 \va
  .endm;
  .macro sidx.noalt3,  p,  i,  s,  i2,  s2,  i3,  s3,  va:vararg
    .altmacro
    sidx.em3 \p, %\i, \s, %\i2, \s2, %\i3, \s3 \va
  .endm;
  .macro sidx.toalt3,  p,  i,  s,  i2,  s2,  i3,  s3,  va:vararg
    .altmacro
    sidx.ema3 \p, %\i, \s, %\i2, \s2, %\i3, \s3 \va
  .endm;
  .macro sidx.em4,  p,  i,  s,  i2,  s2,  i3,  s3,  i4,  s4,  va:vararg
    .noaltmacro
    \p\()$\i\s\()$\i2\s2\()$\i3\s3\()$\i4\s4\va
  .endm;
  .macro sidx.ema4,  p,  i,  s,  i2,  s2,  i3,  s3,  i4,  s4,  va:vararg
    \p\()$\i\s\()$\i2\s2\()$\i3\s3\()$\i4\s4\va
  .endm;
  .macro sidx.alt4,  p,  i,  s,  i2,  s2,  i3,  s3,  va:vararg
    sidx.ema4 \p, %\i, \s, %\i2, \s2, %\i3, \s3, %\i4, \s4, \va
  .endm;
  .macro sidx.noalt4,  p,  i,  s,  i2,  s2,  i3,  s3,  va:vararg
    .altmacro
    sidx.em4 \p, %\i, \s, %\i2, \s2, %\i3, \s3, %\i4, \s4, \va
  .endm;
  .macro sidx.toalt4,  p,  i,  s,  i2,  s2,  i3,  s3,  va:vararg
    .altmacro
    sidx.ema4 \p, %\i, \s, %\i2, \s2, %\i3, \s3, %\i4, \s4, \va
  .endm;
  .noaltmacro
.endif

