10 INPUT "Filename to write", F$
20 h% = OPENOUT(F$)
30 N%=100
40 S$="Hello World " + STR$(N%) 
50 PRINT#h%, S$ : BPUT#h%, 10
55 PRINT#h%, S$ : BPUT#h%, 10
60 CLOSE#h%

100 h% = OPENUP(F$)
120 PTR#h%=EXT#h%
130 PRINT#h%, "And more"
140 CLOSE#h%
