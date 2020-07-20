cd /d %~dp0
python ./GAS_Formatter.py -s out:"../" in:"../_doc/source" doctag:"../_doc" %*
template_exploded.bat -s out:"../_doc/exploded_lines" in:"../_doc/source" %*
