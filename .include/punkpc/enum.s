.ifndef punkpc.library.included
  .include "punkpc.s";.endif;punkpc.module enum, 0x200
.if module.included == 0;  punkpc regs, obj, mut, if;obj.class enum;mut.class enum
  enum.uses_pointers = 1;enum.self_pointers = 0;enum.count_default = 0;enum.step_default = 1
  enumb.count_default = 31;enumb.step_default = -1
  .macro enum.new_raw,  self,  prefix,  suffix,  varg:vararg;  enum.obj \self
    .if ndef;  enum.mut \self;\self\().enum_exiting = 0;\self\().hook enum_parse
      \self\().mut, enum_parse_iter, restart
      .macro \self,  va:vararg;  \self\().enum_conc \prefix, \suffix, \va
      .endm;.macro \self\().enum_conc,  va:vararg;  ifalt;enum.ifalt = alt;.noaltmacro
        \self\().hook.enum_parse \va;ifalt.reset enum.ifalt
      .endm;.macro \self\().restart,  va:vararg;  \self\().hook.restart \va
      .endm;.endif;
  .endm;.macro enum.new_generic,  self,  prefix,  suffix,  varg:vararg
    enum.new_raw \self, \prefix, \suffix
    .if ndef;  \self\().count.restart = 0;\self\().step.restart = 1
      \self\().count = enum.count_default;\self\().step = enum.step_default
      \self\().steps = 0;\self\().last = 0
      \self\().hook enum_parse_iter, numerical, count, step, restart;\self\().mut, literal
    .endif;
  .endm;.macro enum.new,  self,  prefix,  suffix,  va:vararg
    enum.new_generic \self, \prefix, \suffix
    .if ndef;  \self \va;\self\().step.restart = \self\().step
      \self\().count.restart = \self\().count;\self\().count = enum.count_default
      \self\().step = enum.step_default;\self\().mode literal, default;\self \va;.endif;
  .endm;.macro enumb.new,  self,  prefix,  suffix,  varg:vararg
    enum.new_generic \self, \prefix, \suffix
    .if ndef;  \self\().mask = 0;\self\().crf = 0;\self\().mode count, bool
      \self\().count = enumb.count_default;\self\().step = enumb.step_default;\self \varg
      \self\().step.restart = \self\().step;\self\().count.restart = \self\().count
      \self\().mode mask, bool;\self\().mode literal, bool
      \self\().count = enumb.count_default;\self\().step = enumb.step_default;\self \varg
      .macro \self\().mask,  va:vararg;  \self\().mask_conc \prefix, \suffix, \va
      .endm;.macro \self\().mask_conc,  pfx,  sfx,  va:vararg
        .irp arg,  \va
          .ifnb \arg
            .irp conc,  m\arg\sfx;  \self\().hook.mask \pfx\arg\sfx, \pfx\conc;.endr;
          .endif;.endr;
      .endm;.endif;
  .endm;.macro enum.mut.enum_parse.default,  self,  pfx,  sfx,  va:vararg
    .irp arg,  \va;  \self\().enum_exiting = 0
      .ifnb \arg;  \self\().hook.enum_parse_iter \pfx\arg\sfx, \pfx, \sfx, \arg
        .if \self\().enum_exiting > 0
          \self\().enum_exiting = \self\().enum_exiting -1
          .if \self\().enum_exiting == 0;  .exitm;.endif;.endif;.endif;.endr;
  .endm;.macro enum.mut.enum_parse_iter.default,  self,  sym,  pfx,  sfx,  arg,  va:vararg
    ifnum_ascii \arg
    .if num;  \self\().hook.numerical \arg, num, \pfx, \sfx, \va
    .else;  \self\().hook.literal \sym, \pfx, \sfx, \arg, \va;.endif;
  .endm;.macro enum.mut.numerical.default,  self,  arg,  char,  va:vararg
    .if \char == 0x28;  \self\().hook.count \arg, \va
    .elseif \char >= 0x30;  .if \char <= 0x39
        \self\().hook.count \arg, \va;.endif;
    .elseif \char == 0x2B;  \self\().hook.step \arg, \va
    .elseif \char == 0x2D;  \self\().hook.step \arg, \va;.endif;
  .endm;.macro enum.mut.literal.default,  self,  arg,  va:vararg;  \arg = \self\().count
    \self\().hook.count \self\().count + \self\().step;\self\().steps = \self\().steps + 1
  .endm;.macro enum.mut.count.default,  self,  arg,  va:vararg;  \self\().last = \self\().count
    \self\().count = \arg
  .endm;.macro enum.mut.step.default,  self,  arg,  va:vararg;  \self\().step = \arg
  .endm;.macro enum.mut.restart.default,  self,  va:vararg
    \self\().step = \self\().step.restart;\self\().count = \self\().count.restart
  .endm;.macro enum.mut.literal.bool,  self,  sym,  pfx,  sfx,  arg,  va:vararg
    \pfx\()b\arg\sfx = \self\().count & 0x1F;\self\().hook.count \self\().count + \self\().step
    \pfx\()m\arg\sfx = 0x80000000 >> \pfx\()b\arg\sfx
    \self\().steps = \self\().steps + 1;.endm;
  .macro enum.mut.count.bool,  self,  arg,  va:vararg;  \self\().last = \self\().count
    \self\().count = \arg & 0x1F
  .endm;.macro enum.mut.mask.bool,  self,  arg,  mask,  va:vararg;  ifnum \arg
    .if nnum;  ifdef \arg
      .if ndef;  \arg = 0;.endif;
      .if \arg;  \self\().mask = \self\().mask | \mask;enum.__crf_index = \arg >> 2
        \self\().crf = \self\().crf | (1 << enum.__crf_index) & 0xFF;.endif;.endif;
  .endm;enum.new enum.temp;enumb.new enumb.temp, , , -1, (31)
  .macro enum,  va:vararg;  enum.enum_conc, , \va
  .endm;.macro enum.enum_conc,  va:vararg
    .irp p,  last,  count,  step,  steps;  enum.temp.\p = enum.\p;.endr;
    enum.temp.enum_conc \va
    .irp p,  last,  count,  step,  steps;  enum.\p = enum.temp.\p;.endr;
  .endm;.macro enum.restart
    .irp p,  restart.count,  restart.step;  enum.temp.\p = enum.\p;.endr;enum.temp.restart
    .irp p,  count,  step;  enum.\p = enum.temp.\p;.endr;
  .endm;.macro enumb,  va:vararg;  enumb.enum_conc, , \va
  .endm;.macro enumb.enum_conc,  va:vararg
    .irp p,  last,  count,  step,  steps;  enumb.temp.\p = enumb.\p;.endr;
    enumb.temp.enum_conc \va
    .irp p,  last,  count,  step,  steps;  enumb.\p = enumb.temp.\p;.endr;
  .endm;.macro enumb.restart
    .irp p,  count.restart,  step.restart;  enumb.temp.\p = enumb.\p;.endr;enumb.temp.restart
    .irp p,  count,  step;  enumb.\p = enumb.temp.\p;.endr;
  .endm;.macro enumb.mask,  va:vararg
    .irp p,  mask,  crf;  enumb.temp.\p = enumb.\p;.endr;enumb.temp.mask \va
    .irp p,  mask,  crf;  enumb.\p = enumb.temp.\p;.endr;
  .endm;.irp p,  last,  count,  step,  steps,  count.restart,  step.restart
    enum.\p = enum.temp.\p;enumb.\p = enumb.temp.\p;.endr;enumb.mask = 0;enumb.crf = 0;.endif

