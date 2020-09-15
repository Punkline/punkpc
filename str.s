.ifndef str.included;  str.included=0;.endif;
.ifeq str.included;  str.included=3
  .include "./punkpc/ifdef.s"
  .include "./punkpc/ifalt.s"
  str$=0;str.vacount=0;str.logic=0;str.force_litmem=0;str.mRead = 1;str.mWrite=0;str.mLitmem = 2
  str.mStrmem=0;str.mLitio = 4;str.mStrio=0;str.mPrefix = 8;str.mSuffix=0;str.mAltstr = 16
  str.mNoalt=0
  .macro str.logic,  self,  va:vararg;  str.logic = 0;str.logic = 0;str.Altstr = 0;str.Prefix=0
    ifalt
    .if alt;  str.logic = str.logic + str.mAltstr;str.Altstr = str.mAltstr;.endif;
    .if \self\().litmode;  str.logic = str.logic + str.mLitmem;.endif;
    .irp m,  \va;  str.logic = str.logic + str.\m
      .ifc \m,  mPrefix;  str.Prefix=str.mPrefix;.endif;.endr;
  .endm;.macro str.vacount,  va:vararg;  str.vacount=0
    .irp x,  \va;  str.vacount = str.vacount+1;.endr;
  .endm;.macro lit,  va:vararg;  str.force_litmem=1;str \va
  .endm;.macro str,  self,  varg:vararg;  ifalt;ifalt;ifdef \self\().isStr
    .if ndef;  \self\().isStr = 0;.endif;ifalt.reset
    .if \self\().isStr == 0;  str$ = str$ + 1;\self\().isStr = str$;\self\().litmode=0
      \self\().isBlankStr=1;.altmacro;$_str.point$ \self, %\self\().isStr;ifalt.reset
      .macro \self\().conc,  va:vararg;  str.vacount \va
        str.logic \self, mWrite, mStrio, mSuffix;.altmacro
        .if str.vacount>1
          str.strbuf_quoteme \self, %str.logic, \va;.else;
          str.strbuf_dispatch \self, %str.logic, \va;.endif;\self\().isBlankStr=0
      .endm;.macro \self\().pfx,  va:vararg;  str.vacount \va
        str.logic \self, mWrite, mStrio, mPrefix;.altmacro
        .if str.vacount>1
          str.strbuf_quoteme \self, %str.logic, \va;.else;
          str.strbuf_dispatch \self, %str.logic, \va;.endif;\self\().isBlankStr=0
      .endm;.macro \self\().str,  va:vararg;  str.logic \self, mRead, mStrio, mSuffix
        .altmacro;str.strbuf_commasuf \self, %str.logic, \va
      .endm;.macro \self\().strq,  va:vararg;  str.logic \self, mRead, mStrio, mPrefix
        .altmacro;str.strbuf_commapre \self, %str.logic, \va
      .endm;.macro \self\().conclit,  va:vararg;  str.vacount \va
        str.logic \self, mWrite, mLitio, mSuffix;.altmacro
        .if str.vacount>1
          str.strbuf_dispatch \self, %str.logic, , \va;.else;
          str.strbuf_dispatch \self, %str.logic, \va;.endif;\self\().isBlankStr=0
      .endm;.macro \self\().pfxlit,  va:vararg;  str.vacount \va
        str.logic \self, mWrite, mLitio, mPrefix;.altmacro
        .if str.vacount>1
          str.strbuf_dispatch \self, %str.logic, , \va;.else;
          str.strbuf_dispatch \self, %str.logic, \va;.endif;\self\().isBlankStr=0
      .endm;.macro \self\().lit,  va:vararg;  str.logic \self, mRead, mLitio, mSuffix
        .altmacro;str.strbuf_commasuf \self, %str.logic, \va
      .endm;.macro \self\().litq,  va:vararg;  str.logic \self, mRead, mLitio, mPrefix
        .altmacro;str.strbuf_commapre \self, %str.logic, \va
      .endm;.macro \self\().clear;  str.buildstrmem \self;\self\().isblank=1
      .endm;.macro \self\().strbuf_event;  .endm;.endif;str.vacount \varg
    .if str.force_litmem;  str.vacount=2;.endif;str.force_litmem=0
    .if str.vacount>1
      str.buildlitmem \self, , , \varg;.else;  str.buildstrmem \self, \varg;.endif;
  .endm;.macro str.buildstrmem,  self,  strmem;  \self\().litmode = 0
    .purgem \self\().strbuf_event
    .macro \self\().strbuf_event,  cb,  a,  va:vararg
      .if str.Altstr;  str.strbuf_event$\cb \self, <\a>, <\strmem>, \va
      .else;  str.strbuf_event$\cb \self, "\a", "\strmem", \va;.endif;
    .endm;.endm;.macro str.buildlitmem,  self,  pfxmem,  concmem,  litmem:vararg
    \self\().litmode = 1;.purgem \self\().strbuf_event
    .macro \self\().strbuf_event,  cb,  a,  va:vararg
      .if str.Altstr
        .if str.Prefix
          .if \cb == 27;  str.strbuf_event$\cb \self, <\a>, \va <\pfxmem\litmem\concmem>
          .else;  str.strbuf_event$\cb \self, <\a>, \va \pfxmem\litmem\concmem
          .endif;.else;  .if \cb == 19
            str.strbuf_event$\cb \self, <\a>, <\pfxmem\litmem\concmem> \va
          .else;  str.strbuf_event$\cb \self, <\a>, \pfxmem\litmem\concmem \va
          .endif;.endif;
      .else;  .if str.Prefix
          .if \cb == 11;  str.strbuf_event$\cb \self, "\a", \va "\pfxmem\litmem\concmem"
          .else;  str.strbuf_event$\cb \self, "\a", \va \pfxmem\litmem\concmem;.endif;
        .else;  .if \cb == 3
            str.strbuf_event$\cb \self, "\a", "\pfxmem\litmem\concmem" \va
          .else;  str.strbuf_event$\cb \self, "\a", \pfxmem\litmem\concmem \va;.endif;
        .endif;.endif;
    .endm;.endm;.macro str.strbuf_dispatch,  self,  cb,  va:vararg
    .if nalt;  .noaltmacro;.endif;\self\().strbuf_event \cb, \va
  .endm;.macro str.strbuf_quoteme,  self,  cb,  va:vararg
    .if nalt;  .noaltmacro;\self\().strbuf_event \cb, "\va"
    .else;  \self\().strbuf_event \cb, <\va>
    .endif;.endm;.macro str.strbuf_commapre,  self,  cb,  a,  va:vararg;  str.vacount \va
    .if str.vacount == 1
      .ifb \va;  str.vacount = 0;.endif;.endif;
    .if str.vacount
      .if nalt;  .noaltmacro;\self\().strbuf_event \cb, "\a", \va,
      .else;  \self\().strbuf_event \cb, <\a>, \va,
      .endif;.else;  .if nalt;  .noaltmacro;\self\().strbuf_event \cb, "\a"
      .else;  \self\().strbuf_event \cb, <\a>
      .endif;.endif;
  .endm;.macro str.strbuf_commasuf,  self,  cb,  a,  va:vararg;  str.vacount \va
    .if str.vacount
      .if nalt;  .noaltmacro;\self\().strbuf_event \cb, "\a", \va
      .else;  \self\().strbuf_event \cb, <\a>, \va
      .endif;.else;  .if nalt;  .noaltmacro;\self\().strbuf_event \cb, "\a"
      .else;  \self\().strbuf_event \cb, <\a>
      .endif;.endif;
  .endm;.macro str.errors,  str,  va:vararg;  .error "\str"
    .ifnb \va;  str.errors \va;.endif;
  .endm;.macro str.error,  va:vararg;  ifalt
    .if alt;  str.error_alt \va
    .else;  str.error_nalt \va;.endif;
  .endm;.macro str.error_alt,  str,  conc,  va:vararg
    .ifnb \va;  str.error_alt <\str\conc>, \va
    .else;  .error "\str\conc";.endif;
  .endm;.macro str.error_nalt,  str,  conc,  va:vararg
    .ifnb \va;  str.error_nalt "\str\conc", \va
    .else;  .error "\str\conc";.endif;
  .endm;.macro str.point,  point=str.point,  m,  va:vararg;  ifalt;str.vacount \va;.altmacro
    str.point_evaluation %\point, <\m>, \va
  .endm;.macro str.point_evaluation,  point,  m,  va:vararg;  ifalt.reset
    .if alt;  $_str.point$\point <\m>, \va
    .else;  $_str.point$\point "\m", \va;.endif;
  .endm;.macro $_str.point$,  self,  id
    .macro $_str.point$\id,  m,  va:vararg
      .if str.vacount;  \m \self, \va
      .else;  \m \self;.endif;
    .endm;.endm;.macro str.point.get,  str;  ndef=0;def=1
    .irpc c,  \str
      .irpc n,  0123456789
        .ifc \c,  \n;  def=0;.endif;.endr;.exitm;.endr;
    .if def;  ifdef \str\().isStr;.endif;
    .if def;  str.point = \str\().isStr
    .else;  str.point = \str;.endif;
  .endm;.macro str.irp,  str,  va:vararg;  str.point.get \str;str.point, str.irp_handle, 0, \va
  .endm;.macro str.irpq,  str,  va:vararg;  str.point.get \str
    str.point, str.irp_handle, 1, \va
  .endm;.macro str.irp_handle,  str,  q,  m,  va:vararg;  str str.irp ".irp item,"
    str.vacount \va
    .if str.vacount == 1
      .ifb \va;  str.vacount=0;.endif;.endif;
    .if str.vacount
      .if \q;  \str\().litq str.irp.conc;str.irp.conc "; \m \va, \item; .endr"
      .else;  \str\().litq str.irp.conc;str.irp.conc "; \m \item, \va; .endr";.endif;
    .else;  \str\().litq str.irp.conc;str.irp.conc "; \m \item; .endr";.endif;str.irp.lit
  .endm;.macro str.str,  str,  va:vararg;  str.point.get \str
    str.point, str.read_handle, str, \va
  .endm;.macro str.lit,  str,  va:vararg;  str.point.get \str
    str.point, str.read_handle, lit, \va
  .endm;.macro str.strq,  str,  va:vararg;  str.point.get \str
    str.point, str.read_handle, strq, \va
  .endm;.macro str.litq,  str,  va:vararg;  str.point.get \str
    str.point, str.read_handle, litq, \va
  .endm;.macro str.read_handle,  str,  method,  cb,  va:vararg;  str.vacount \va
    .if str.vacount == 1
      .ifb \va;  str.vacount=0;.endif;.endif;
    .if str.vacount;  \str\().\method \cb, \va
    .else;  \str\().\method \cb;.endif;
  .endm;.macro str.strbuf_event$0,  self,  a,  str,  va:vararg;  str.buildstrmem \self, "\str\a"
  .endm;.macro str.strbuf_event$1,  self,  a,  str,  va:vararg;  \a "\str" \va
  .endm;.macro str.strbuf_event$2,  self,  a,  va:vararg;  str.buildlitmem \self, , "\a", \va
  .endm;.macro str.strbuf_event$3,  self,  a,  va:vararg;  \a \va
  .endm;.macro str.strbuf_event$4,  self,  a,  str,  va:vararg
    str.buildlitmem \self, , \a, \str\va
  .endm;.macro str.strbuf_event$5,  self,  a,  str,  va:vararg;  \a \str \va
  .endm;.macro str.strbuf_event$6,  self,  a,  va:vararg;  str.buildlitmem \self, , \a, \va
  .endm;.macro str.strbuf_event$7,  self,  a,  va:vararg;  \a \va
  .endm;.macro str.strbuf_event$8,  self,  a,  str,  va:vararg;  str.buildstrmem \self, "\a\str"
  .endm;.macro str.strbuf_event$9,  self,  a,  str,  va:vararg;  \a "\str" \va
  .endm;.macro str.strbuf_event$10,  self,  a,  va:vararg;  str.buildlitmem \self, "\a", , \va
  .endm;.macro str.strbuf_event$11,  self,  a,  va:vararg;  \a \va
  .endm;.macro str.strbuf_event$12,  self,  a,  str,  va:vararg
    str.buildlitmem \self, \a, , \va\str
  .endm;.macro str.strbuf_event$13,  self,  a,  str,  va:vararg;  \a \va \str
  .endm;.macro str.strbuf_event$14,  self,  a,  va:vararg;  str.buildlitmem \self, \a, , \va
  .endm;.macro str.strbuf_event$15,  self,  a,  va:vararg;  \a \va
  .endm;.macro str.strbuf_event$16,  self,  a,  str,  va:vararg;  str.buildstrmem \self, <\str\a>
  .endm;.macro str.strbuf_event$17,  self,  a,  str,  va:vararg;  \a <\str> \va
  .endm;.macro str.strbuf_event$18,  self,  a,  va:vararg;  str.buildlitmem \self, , <\a>, \va
  .endm;.macro str.strbuf_event$19,  self,  a,  va:vararg;  \a \va
  .endm;.macro str.strbuf_event$20,  self,  a,  str,  va:vararg
    str.buildlitmem \self, , \a, \str\va
  .endm;.macro str.strbuf_event$21,  self,  a,  str,  va:vararg;  \a \str \va
  .endm;.macro str.strbuf_event$22,  self,  a,  va:vararg;  str.buildlitmem \self, , \a, \va
  .endm;.macro str.strbuf_event$23,  self,  a,  va:vararg;  \a \va
  .endm;.macro str.strbuf_event$24,  self,  a,  str,  va:vararg;  str.buildstrmem \self, <\a\str>
  .endm;.macro str.strbuf_event$25,  self,  a,  str,  va:vararg;  \a <\str> \va
  .endm;.macro str.strbuf_event$26,  self,  a,  va:vararg;  str.buildlitmem \self, <\a>, , \va
  .endm;.macro str.strbuf_event$27,  self,  a,  va:vararg;  \a \va
  .endm;.macro str.strbuf_event$28,  self,  a,  str,  va:vararg
    str.buildlitmem \self, \a, , \va\str
  .endm;.macro str.strbuf_event$29,  self,  a,  str,  va:vararg;  \a \va \str
  .endm;.macro str.strbuf_event$30,  self,  a,  va:vararg;  str.buildlitmem \self, \a, , \va
  .endm;.macro str.strbuf_event$31,  self,  a,  va:vararg;  \a \va
  .endm;.endif;

