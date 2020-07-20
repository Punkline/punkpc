.ifndef enum.included
  enum.included = 0
.endif;
.ifeq enum.included
  enum.included = 1
  .include "./punkpc/ifdef.s"
  .macro enum,  va:vararg
    .irp a,  \va
      a=1
      .irpc c,  \a
        .irpc i,  -+
          .ifc \c,  \i
            enum.step=\a
            a=0
          .endif;
          .ifc \c,  (
            enum.count=\a
            a=0
          .endif;
        .endr;
        .exitm
      .endr;
      .if a
        \a=enum.count
        enum.count=enum.count+enum.step
      .endif;
    .endr;
  .endm;
  enum.count=0
  enum.step=1
  .macro enumb,  va:vararg
    .irp a,  \va
      a=1
      .irpc c,  \a
        .irpc i,  -+
          .ifc \c,  \i
            enumb.step=\a
            a=0
          .endif;
          .ifc \c,  (
            enumb.count=\a
            a=0
          .endif;
        .endr;
        .exitm
      .endr;
      .if a
        b\a=enumb.count
        enumb.count=enumb.count+enumb.step
        m\a=0x80000000>>b\a
      .endif;
    .endr;
  .endm;
  .macro enumb.mask,  va:vararg
    i=0
    .irp a,  \va
      ifdef \a
      .if ndef
        \a=0
      .endif;
      ifdef m\()\a
      .if ndef
        m\()\a=0
      .endif;
      i=i|(m\a&(\a!=0))
    .endr;
    enumb.mask=i
    enumb.crf=0
    .rept 8
      enumb.crf=(enumb.crf<<1)|!!(i&0xF)
      i=i<<4
    .endr;
  .endm;
  enumb.count=31
  enumb.step=-1
.endif

