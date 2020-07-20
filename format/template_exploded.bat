cd /d %~dp0
python ./GAS_Formatter.py out:"./output" -mc+skpie width:0 indent:".macro,.if,.else,.rept,.irp" outdent:".endm,.endif,.else,.endr" %*