cd /d %~dp0
python ./GAS_Formatter.py out:"./output" +skpicem width:300 comma_ws:"" semicol_ws:"" argdef_ws:" "  indent:".macro ,.if,.else,.rept,.irp" outdent:".endm,.endif,.else,.endr" thisnl:".macro,.if,.else,.rept,.irp,.endm,.include" nextnl:"LOCAL,.include " %*
