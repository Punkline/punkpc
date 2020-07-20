cd /d %~dp0
python ./GAS_Formatter.py out:"./output" -kpicm+se width:-1 comma_ws:"" semicol_ws:"" argdef_ws:"  " %*
