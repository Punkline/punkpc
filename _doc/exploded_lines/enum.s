.ifndef enum.included
  enum.included = 0
.endif;
.ifeq enum.included
  enum.included = 5
  .include "./punkpc/ifdef.s"
  .include "./punkpc/xem.s"
  enum$=0
  enumb$=0
  .macro enum.new,  self,  pfx,  varg:vararg
    ifdef \self\().isEnum
    .if ndef
      enum$ = enum$ + 1
      \self\().isEnum = enum$
      \self\().count = 0
      \self\().last = 0
      \self\().step = 1
      \self\().bool.count = 31
      \self\().bool.last = 0
      \self\().bool.step = -1
      \self\().mask = 0
      \self\().crf = 0
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
            \self\().last=\self\().count
            \self\().count=\self\().count + \self\().step
            \self\().enum_callback \self, \pfx\a, \pfx, \a
          .endif;
        .endr;
      .endm;
      .macro \self\().bool,  va:vararg
        .irp a,  \va
          a=1
          .irpc c,  \a
            .irpc i,  -+
              .ifc \c,  \i
                \self\().bool.step=\a
                a=0
              .endif;
              .ifc \c,  (
                \self\().bool.count=\a
                a=0
              .endif;
            .endr;
            .exitm
          .endr;
          .if a
            ifdef \pfx\a
            .if ndef
              \pfx\a = 0
            .endif;
            \pfx\()b\a = \self\().bool.count
            \pfx\()m\a = 0x80000000 >> \pfx\()b\a
            \self\().bool.last=\self\().bool.count
            \self\().bool.count = \self\().bool.count + \self\().bool.step
            \self\().enum.bool_callback \self, \pfx\a, \pfx, \a
          .endif;
        .endr;
      .endm;
      .macro \self\().mask,  va:vararg
        i=0
        a=0
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
          a=a | (\pfx\()m\a)
        .endr;
        \self\().mask=i
        \self\().crf=0
        .rept 8
          \self\().crf=(\self\().crf<<1)|!!(a&0xF0000000)
          a=a<<4
        .endr;
        crf = \self\().crf
        \self\().enum.mask_callback \self, \pfx
      .endm;
      .macro \self\().restart
        \self\().enum.restart_callback \self, \pfx
        \self\().count = \self\().count.restart
        \self\().step = \self\().step.restart
      .endm;
      .macro \self\().bool.restart
        \self\().enum.bool.restart_callback \self, \pfx
        \self\().bool.count = \self\().bool.count.restart
        \self\().bool.step = \self\().bool.step.restart
      .endm;
      .macro \self\().enum_callback,  obj,  symbol,  prefix,  suffix
      .endm;
      .macro \self\().enum.bool_callback,  obj,  symbol,  prefix,  suffix
      .endm;
      .macro \self\().enum.mask_callback,  obj,  prefix
      .endm;
      .macro \self\().enum.restart_callback,  obj,  prefix
      .endm;
      .macro \self\().enum.bool.restart_callback,  obj,  prefix
      .endm;
      .ifnb \varg
        \self \varg
      .endif;
      \self\().count.restart = \self\().count
      \self\().step.restart = \self\().step
      \self\().bool.count.restart = \self\().bool.count
      \self\().bool.step.restart = \self\().bool.step
    .endif;
  .endm;
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
        enum.last=enum.count
        enum.count=enum.count + enum.step
        enum.enum_callback enum, \pfx\a, \pfx
      .endif;
    .endr;
  .endm;
  .macro enum.bool.pfx,  pfx,  va:vararg
    .irp a,  \va
      a=1
      .irpc c,  \a
        .irpc i,  -+
          .ifc \c,  \i
            enum.bool.step=\a
            a=0
          .endif;
          .ifc \c,  (
            enum.bool.count=\a
            a=0
          .endif;
        .endr;
        .exitm
      .endr;
      .if a
        ifdef \pfx\a
        .if ndef
          \pfx\a = 0
        .endif;
        \pfx\()b\a = enum.bool.count
        \pfx\()m\a = 0x80000000 >> \pfx\()b\a
        enum.bool.last=enum.bool.count
        enum.bool.count = enum.bool.count + enum.bool.step
        enum.enum_callback enum, \pfx\a, \pfx
      .endif;
    .endr;
  .endm;
  .macro enum.mask.pfx,  pfx,  va:vararg
    i=0
    a=0
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
      a=a | (\pfx\()m\a)
    .endr;
    enum.mask=i
    enum.crf=0
    .rept 8
      enum.crf=(enum.crf<<1)|!!(a&0xF0000000)
      a=a<<4
    .endr;
    crf = enum.crf
    enum.enum.mask_callback enum, \pfx
  .endm;
  enum.new enum
  enum.new enumb
  .purgem enumb
  .purgem enumb.restart
  .macro enumb,  va:vararg
    enumb.bool \va
  .endm;
  .macro enumb.restart,  va:vararg
    enumb.bool.restart \va
  .endm;
  .macro enumb.pfx,  va:vararg
    enum.bool.pfx \va
    enumb.crf = enum.crf
    enumb.mask = enum.mask
    enumb.bool.count = enum.bool.count
    enumb.count = enumb.bool.count
    enumb.bool.step = enum.bool.step
    enumb.step = enum.bool.step
    enumb.bool.last = enum.bool.last
    enumb.last = enum.bool.last
  .endm;
  .macro enumb.mask.pfx,  va:vararg
    enum.bool.pfx \va
    enumb.mask = enum.mask
    enumb.crf = enum.crf
  .endm;
.endif;

