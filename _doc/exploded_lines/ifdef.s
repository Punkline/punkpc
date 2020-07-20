.ifndef ifdef.included
  ifdef.included = 0
.endif;
.ifeq ifdef.included
  ifdef.included = 1
  .macro ifdef,  sym
    .altmacro
    ifdef.alt \sym
    .noaltmacro
  .endm;
  .macro ifdef.alt,  sym
    def=0
    .ifdef sym
      def=1
    .endif;
    ndef=def^1
  .endm;
.endif;

