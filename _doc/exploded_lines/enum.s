.ifndef enum.included
  enum.included = 0
.endif;
.ifeq enum.included
  enum.included = 3
  .include "./punkpc/ifdef.s"
  .include "./punkpc/xem.s"
  enum$=0
  enumb$=0
  .macro enum.new,  self,  pfx,  varg:vararg
    ifdef \self\().isEnum
    .if ndef
      enum$ = enum$ + 1
      \self\().isEnum = enum$
      \self\().count=0
      \self\().step=1
      .macro \self,  va:vararg
        .irp a,  \va
          a=1
          .irpc c,  \a
            .irpc i,  -+
              .ifc \c,  \i
                \self\().step=\a
                a=0
              .endif;
              .ifc \c,  (
                \self\().count=\a
                a=0
              .endif;
            .endr;
            .exitm
          .endr;
          .if a
            \pfx\a=\self\().count
            \self\().count=\self\().count + \self\().step
          .endif;
        .endr;
      .endm;
      .ifnb \varg
        \self \varg
      .endif;
    .endif;
  .endm;
  .macro enumb.new,  self,  pfx,  varg:vararg
    ifdef \self\().isEnumb
    .if ndef
      enumb$ = enumb$ + 1
      \self\().isEnumb = enumb$
      \self\().count=31
      \self\().step=-1
      .macro \self,  va:vararg
        .irp a,  \va
          a=1
          .irpc c,  \a
            .irpc i,  -+
              .ifc \c,  \i
                \self\().step=\a
                a=0
              .endif;
              .ifc \c,  (
                \self\().count=\a
                a=0
              .endif;
            .endr;
            .exitm
          .endr;
          .if a
            \pfx\()b\a = \self\().count
            \pfx\()m\a = 0x80000000 >> \pfx\()b\a
            \self\().count = \self\().count + \self\().step
          .endif;
        .endr;
      .endm;
      .macro \self\().mask,  va:vararg
        i=0
        .irp a,  \va
          ifdef \pfx\a
          .if ndef
            \pfx\a=0
          .endif;
          ifdef \pfx\()m\()\a
          .if ndef
            \pfx\()m\()\a=0
          .endif;
          i=i | (\pfx\()m\a & (\pfx\a != 0))
        .endr;
        \self\().mask=i
        \self\().crf=0
        .rept 8
          \self\().crf=(\self\().crf<<1)|!!(i&0xF)
          i=i<<4
        .endr;
      .endm;
      .ifnb \varg
        \self \varg
      .endif;
    .endif;
  .endm;
  enum.new enum
  enumb.new enumb
  .macro enum.pfx,  pfx,  va:vararg
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
        \pfx\a=enum.count
        enum.count=enum.count + enum.step
      .endif;
    .endr;
  .endm;
  .macro enumb.pfx,  pfx,  va:vararg
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
        \pfx\()b\a=enumb.count
        enumb.count=enumb.count+enumb.step
        \pfx\()m\a=0x80000000>>\pfx\()b\a
      .endif;
    .endr;
  .endm;
  .macro enumb.mask.pfx,  pfx,  va:vararg
    i=0
    .irp a,  \va
      ifdef \pfx\a
      .if ndef
        \pfx\a=0
      .endif;
      ifdef \pfx\()m\()\a
      .if ndef
        \pfx\()m\()\a=0
      .endif;
      i=i | (\pfx\()m\a & (\pfx\a != 0))
    .endr;
    enumb.mask=i
    enumb.crf=0
    .rept 8
      enumb.crf=(enumb.crf<<1)|!!(i&0xF)
      i=i<<4
    .endr;
  .endm;
.endif;

