10 REM Sprite editor test
15 ON ERROR GOTO 5000
20 MODE 8
30 SW%=320 : SH%=240
40 COL%=3
50 GRIDX%=16 : GRIDY%=16 : W%=16 : H%=16
55 DIM G%(W%*H%) : FOR I%=0 TO W%*H%-1 : G%(I%)=0
60 PALX%=160 : PALY%=16
62 GRIDCOL%=8 : CURSCOL%=15
65 exit=0
70 VDU 23,0,192,0 : REM turn off logical screen scaling
75 VDU 23, 1, 0 : REM disable text cursor
80 PROCdrawgrid(W%,H%,GRIDX%,GRIDY%)
90 PROCdrawpalette(PALX%,PALY%)
100 PROCselectcol(1)
110 PX%=0 : PY%=0
112 PRINT TAB(30,0);"COL ";COL%
114 PROCgridcursor(1)
140 REM Main Loop
150 REPEAT
160 key=INKEY(0)
170 REM IF key > -1 PRINT TAB(0,0);"     ": PRINT TAB(0,0);key
172 REM left=8, right=21, up=11, down=10, tab=9, nums 0=48 ... 9=57
174 REM q=110, x=120, s=115, spc=32, w,a,s,d = 119,97,115,100
176 REM a=97 ... z=122, ","=44, "."=46  backspace=127 c=99
180 IF key=-1 GOTO 490
190 PROCgridcursor(0)
200 IF key = 120 exit=1 : REM x=exit
205 REM W,A,S,D for grid cursor movement
210 IF key = 97 AND PX%>0 THEN PX%=PX%-1
220 IF key = 100 AND PX%<15 THEN PX%=PX%+1
230 IF key = 119 AND PY%>0 THEN PY%=PY%-1
240 IF key = 115 AND PY%<15 THEN PY%=PY%+1
250 REM cursor key for colour select movement
260 IF key = 11 AND COL%>0 THEN PROCselectcol(COL%-1)
270 IF key = 10 AND COL%<63 THEN PROCselectcol(COL%+1)
280 IF key = 8 AND COL%>15 THEN PROCselectcol(COL%-16)
290 IF key = 21 AND COL%<47 THEN PROCselectcol(COL%+16)
295 REM space = set colour, backspace = delete (set to 0), f=fill to current col
300 IF key = 32 THEN PROCsetcol(PX%,PY%,COL%)
310 IF key = 127 THEN PROCsetcol(PX%,PY%,0)
320 IF key = 99 THEN PROCcleargrid(0)
330 IF key = 102 THEN PROCcleargrid(COL%)
340 PROCgridcursor(1)
350 PRINT TAB(34,0);"  ";TAB(30,0);"COL ";COL%
490 UNTIL exit = 1
500 GOTO 5000

998 :
999 STOP
1000 REM PROC drawgrid
1010 DEF PROCdrawgrid(w%,h%,x%,y%)
1020 GCOL 0,GRIDCOL%
1030 FOR Y%=0 TO h%
1040 PLOT 4, x%, y%+Y%*8
1045 PLOT 5, x%+w%*8, y%+Y%*8
1050 NEXT Y%
1060 FOR X%=0 TO w%
1070 PLOT 4, x%+X%*8, y%
1075 PLOT 5, x%+X%*8, y%+h%*8
1080 NEXT
1090 ENDPROC

1200 REM PROC drawpalette
1210 DEF PROCdrawpalette(x%,y%)
1220 FOR N%=0 TO 3
1230 FOR I%=0 TO 15
1240 PROCFilledRect(1.5+x%+N%*10,0.5+y%+I%*10,7,7,I%+N%*16)
1250 NEXT I%
1260 NEXT N%
1270 ENDPROC

1300 REM select col
1310 DEF PROCselectcol(c%)
1320 x% = COL% DIV 16 : y% = COL% MOD 16
1330 PROCRect(PALX%+x%*10, PALY%+y%*10, 8, 8, 0)
1340 COL%=c%
1350 x% = COL% DIV 16 : y% = COL% MOD 16
1360 PROCRect(PALX%+x%*10, PALY%+y%*10, 8, 8, 15)
1370 ENDPROC

1400 REM draw gridcursor
1410 DEF PROCgridcursor(switch%)
1420 col%=GRIDCOL% : REM off
1430 IF switch%=1 THEN col%=CURSCOL% : REM on
1440 PROCRect(GRIDX%+PX%*8, GRIDY%+PY%*8, 8, 8, col%)
1490 ENDPROC

1500 REM set colour in grid
1510 DEF PROCsetcol(x%,y%,c%)
1520 G%(x%+y%*W%)=c%
1530 PROCFilledRect(GRIDX%+x%*8, GRIDY%+y%*8, 8, 8, c%)
1590 ENDPROC

1600 REM clear grid to a colour
1610 DEF PROCcleargrid(col%)
1620 FOR i%=0 TO W%-1
1630 FOR j%=0 TO H%-1
1640 G%(i%+j%*W%)=col%
1650 NEXT 
1660 NEXT
1670 PROCFilledRect(GRIDX%,GRIDY%, W%*8,H%*8,col%)
1680 PROCdrawgrid(W%,H%,GRIDX%,GRIDY%)
1690 ENDPROC

2000 REM PROCFilledRect draw a filled rectangle
2001 REM assume screen scaling OFF
2010 DEF PROCFilledRect(x%,y%,w%,h%,c%)
2020 GCOL 0,c%
2030 MOVE x%,y% 
2040 MOVE x%+w%,y% : PLOT 80, x%+w%, y%+h%
2050 MOVE x%, y%+h% : PLOT 80, x%, y%
2060 ENDPROC

2100 REM PROCRect draw a rectangle
2101 REM assume screen scaling OFF
2110 DEF PROCRect(x%,y%,w%,h%,c%)
2120 GCOL 0,c%
2130 MOVE x%,y% 
2140 DRAW x%+w%,y% 
2150 DRAW x%+w%, y%+h%
2160 DRAW x%, y%+h% 
2170 DRAW x%, y%
2180 ENDPROC

5000 REM Error Handling
5010 VDU 23, 0, 192, 1 : REM turn on normal logical screen scaling
5020 VDU 23, 1, 1 : REM enable text cursor
5030 PRINT:REPORT:PRINT " at line ";ERL:END
5040 PRINT "Goodbye"
