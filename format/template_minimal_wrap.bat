cd /d %~dp0
python ./GAS_Formatter.py out:"./output" -mck+pie width:99 comma_ws:"" semicol_ws:"" argdef_ws:"  " indent:".macro " outdent:".endm" thisnl:".macro " nextnl:"LOCAL,.include " %*
