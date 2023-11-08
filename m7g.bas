05 REM Mode 7 Graphics example - converted from BBC Micro User Guide for Agon BASIC
10 DIM S% 7
15 REM Lookup table for bit->ascii
20 !S%=&08040201
30 S%!4=&4010
35 :
40 PROCinitGraphics
50 PRINT TAB(0,22);: VDU 132,157,132: PRINT TAB(7,22);: VDU 131,157,132,141 : PRINT "  MODE 7 GRAPHICS    ";:VDU 157
55 PRINT TAB(0,23);: VDU 132,157,132: PRINT TAB(7,23);: VDU 131,157,132,141 : PRINT "  MODE 7 GRAPHICS    ";:VDU 157

70 REM Draw a Sine Curve
80 FOR X=0 TO 75 STEP 0.25
90 PROCPLOT(X,28+28*SIN(X/10))
95 PROCPLOT(X,28-28*SIN(X/10))
100 NEXT
110 FOR X=0 TO 75 STEP 0.25
120 PROCPLOT(X,28+28*COS(X/10))
125 PROCPLOT(X,28-28*COS(X/10))
130 NEXT
140 PRINT TAB(0,24);
195 END

200 DEF PROCinitGraphics
205 REM Put graphics char down left of screen from Y=1 to Y=19
210 LOCAL Y%
220 MODE 7
230 FOR Y%=0 TO 18
235 REM Move down a line, put &97 at beginning of line
240 VDU 10,13,&97
250 NEXT
260 ENDPROC

300 DEF PROCPLOT(X%,Y%)
305 REM Plot a single graphics "point" in Mode 7 
310 LOCAL C%,A%,CX%,CY%, H%
320 REM Move cursor
330 CX%=X% DIV2+1 : CY%=19-Y% DIV3 : REM Character positions
350 REM Calculate ASCII char with this point
360 C%=S%?((X% AND 1)+(2-Y%MOD3)*2)+160
370 REM Get char already there
380 H% = ASC(GET$(CX%, CY%))
390 REM write new character combining existing and new points
400 PRINT TAB(CX%, CY%);
410 VDU H% OR C% OR 128
420 ENDPROC
