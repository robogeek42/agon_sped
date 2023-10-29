10 REM Sprite editor test
20 ON ERROR GOTO 5000
30 MODE 8
40 SW%=320 : SH%=240
50 COL%=3
60 GRIDX%=16 : GRIDY%=16 : W%=16 : H%=16
70 DIM G%(W%*H%) : FOR I%=0 TO W%*H%-1 : G%(I%)=0
75 DIM CL%(63) : DIM RGB%(64*3) : PROCloadLUT
79 REM palette x/y and sprite x/y positions on screen
80 PALX%=160 : PALY%=16 : SPX%=16 : SPY%=160
85 PX%=0 : PY%=0 : REM selected palette position
90 GRIDCOL%=8 : CURSCOL%=15 :ISEXIT=0
100 DIM KEYG(4), KEYP(4) : REM in order left, right, up down 
102 KEY_SET=32 : KEY_DEL=127 : PROCsetkeys
104 PROCcreateSprite(W%,H%)
140 PROCdrawScreen
200 REM Main Loop
210 REPEAT
220 key=INKEY(0)
225 UPDATESPRITE=0
230 REM IF key > -1 PRINT TAB(0,0);"     ": PRINT TAB(0,0);key
240 REM left=8, right=21, up=11, down=10, tab=9, nums 0=48 ... 9=57
250 REM q=110, x=120, s=115, spc=32, w,a,s,d = 119,97,115,100
260 REM a=97 ... z=122, ","=44, "."=46  backspace=127 c=99
270 IF key=-1 GOTO 470
280 PROCgridcursor(0)
290 IF key = 120 ISEXIT=1 : REM x=exit
300 REM grid cursor movement
310 IF key = KEYG(0) AND PX%>0 THEN PX%=PX%-1 : REM left
320 IF key = KEYG(1) AND PX%<15 THEN PX%=PX%+1 : REM right
330 IF key = KEYG(2) AND PY%>0 THEN PY%=PY%-1 : REM up
340 IF key = KEYG(3) AND PY%<15 THEN PY%=PY%+1 : REM down
350 REM colour select movement
360 IF key = KEYP(0) AND COL%>15 THEN PROCselectcol(COL%-16) : REM left
370 IF key = KEYP(1) AND COL%<47 THEN PROCselectcol(COL%+16) : REM right
380 IF key = KEYP(2) AND COL%>0 THEN PROCselectcol(COL%-1) : REM up
390 IF key = KEYP(3) AND COL%<63 THEN PROCselectcol(COL%+1) : REM down
400 REM space = set colour, backspace = delete (set to 0), f=fill to current col
410 IF key = 32 THEN PROCsetcol(PX%,PY%,COL%) : UPDATESPRITE=1
420 IF key = 127 THEN PROCsetcol(PX%,PY%,0) : UPDATESPRITE=1
430 IF key = 99 THEN PROCcleargrid(0) : UPDATESPRITE=1
440 IF key = 102 THEN PROCcleargrid(COL%) : UPDATESPRITE=1
450 PROCprintColour(27,2)
460 IF UPDATESPRITE=1 THEN PROCshowSprite
470 PROCgridcursor(1)
480 UNTIL ISEXIT = 1
500 GOTO 5000

700 REM draw screen 
710 DEF PROCdrawScreen
720 VDU 23,0,192,0 : REM turn off logical screen scaling
730 VDU 23, 1, 0 : REM disable text cursor
740 PROCdrawgrid(W%,H%,GRIDX%,GRIDY%)
750 PROCdrawpalette(PALX%,PALY%)
760 PROCselectcol(1)
770 PROCprintColour(27,2)
780 PROCgridcursor(1)
790 PROCRect(SPX%-2, SPY%-2, W%+3, H%+3, GRIDCOL%)
800 COLOUR 41:PRINT TAB(0,0);"SPRITE EDITOR"
810 COLOUR 20:PRINT TAB(14,0);"for Agon"
820 GCOL 0,15 : MOVE 0,10 : DRAW 320,10
830 GCOL 0,15 : MOVE 0,26*8-2 : DRAW 320,26*8-2
840 COLOUR 21 : PRINT TAB(0,26);"Cursor"; :COLOUR 19:PRINT TAB(7,26);"Move in grid";
850 COLOUR 21 : PRINT TAB(0,27);"WASD  "; :COLOUR 19:PRINT TAB(7,27);"Select palette";
860 COLOUR 21 : PRINT TAB(0 ,28);"Space"; :COLOUR 19:PRINT TAB(7,28);"Set";
870 COLOUR 21 : PRINT TAB(0 ,29);"F";     :COLOUR 19:PRINT TAB(7,29);"Fill";
880 COLOUR 21 : PRINT TAB(14,28);"Backsp";:COLOUR 19:PRINT TAB(21,28);"Clear";
890 COLOUR 21 : PRINT TAB(14,29);"X";     :COLOUR 19:PRINT TAB(21,29);"Exit";
900 COLOUR 21 : PRINT TAB(30,28);"S";     :COLOUR 19:PRINT TAB(33,28);"Save";
910 COLOUR 21 : PRINT TAB(30,29);"L";     :COLOUR 19:PRINT TAB(33,29);"Load";
980 COLOUR 15
990 ENDPROC

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

1700 REM setup the sprite and bitmap
1710 DEF PROCcreateSprite(w,h)
1720 VDU 23,27,0,0: REM Select bitmap 0
1725 VDU 23,27,1,w;h;
1730 FOR I%=1 TO w*h : VDU 0,0,0,1 : NEXT
1740 VDU 23,27,4,0: REM Select sprite 0
1745 VDU 23,27,5: REM Clear frames for current sprite
1750 VDU 23,27,6,0: REM Add bitmap 0 as frame 0 of sprite
1755 VDU 23,27,11: REM Show the sprite
1760 VDU 23,27,7,1 : REM activate 1 sprite
1770 VDU 23,27,4,0,23,27,13,SPX%; SPY%;
1790 ENDPROC

1800 REM show sprite
1810 DEF PROCshowSprite
1820 VDU 23,27,0,0: REM Select bitmap 0
1825 VDU 23,27,1,W%;H%;
1830 FOR I%=0 TO W%*H%-1
1840 clu%=CL%(G%(I%))
1850 VDU RGB%(clu%*3), RGB%(clu%*3+1), RGB%(clu%*3+2), 255
1870 NEXT
1880 VDU 23,27,4,0,23,27,13,SPX%; SPY%;
1890 ENDPROC

1900 REM print colour
1910 DEF PROCprintColour(x%,y%)
1920 clu%=CL%(COL%)
1930 PRINT TAB(x%,y%);SPC(4); : PRINT TAB(x%,y%+1);SPC(13);
1940 COLOUR 15: PRINT TAB(x%,y%);"COL ";COL%;
1945 REM Decimal below
1950 REM COLOUR 9 : PRINT TAB(x%,y%+1);RGB%(clu%*3);
1955 REM COLOUR 10: PRINT TAB(x%+4,y%+1);RGB%(1+clu%*3);
1960 REM COLOUR 12: PRINT TAB(x%+8,y%+1);RGB%(2+clu%*3);
1965 REM hex
1970 COLOUR 9 : PRINT TAB(x%+7,y%);"00";
1972 COLOUR 9 : PRINT TAB(x%+7,y%);~RGB%(clu%*3);
1975 COLOUR 10: PRINT TAB(x%+9,y%);"00";
1977 COLOUR 10: PRINT TAB(x%+9,y%);~RGB%(1+clu%*3);
1980 COLOUR 12: PRINT TAB(x%+11,y%);"00";
1982 COLOUR 12: PRINT TAB(x%+11,y%);~RGB%(2+clu%*3);
1985 COLOUR 15
1990 ENDPROC

2000 DEF PROCsetkeys
2004 REM arrows left=8, right=21, up=11, down=10
2005 REM w,a,s,d = w=119(up),a=97(left),s=115(down),d=100(right)
2010 KEYG(0)=8 : KEYG(1)=21 : KEYG(2)=11 : KEYG(3)=10 
2020 KEYP(0)=97 : KEYP(1)=100 : KEYP(2)=119 : KEYP(3)=115 
2090 ENDPROC

3000 REM PROCFilledRect draw a filled rectangle
3001 REM assume screen scaling OFF
3010 DEF PROCFilledRect(x%,y%,w%,h%,c%)
3020 GCOL 0,c%
3030 MOVE x%,y% 
3040 MOVE x%+w%,y% : PLOT 80, x%+w%, y%+h%
3050 MOVE x%, y%+h% : PLOT 80, x%, y%
3060 ENDPROC

3100 REM PROCRect draw a rectangle
3101 REM assume screen scaling OFF
3110 DEF PROCRect(x%,y%,w%,h%,c%)
3120 GCOL 0,c%
3130 MOVE x%,y% 
3140 DRAW x%+w%,y% 
3150 DRAW x%+w%, y%+h%
3160 DRAW x%, y%+h% 
3170 DRAW x%, y%
3180 ENDPROC

4000 REM Colour - RGB Look up
4010 DEF PROCloadLUT
4025 RESTORE
4030 FOR I%=0 TO 63 
4040 READ CL%(I%)
4050 NEXT
4060 FOR I%=0 TO 63
4070 READ RGB%(I%*3),RGB%(I%*3+1),RGB%(I%*3+2)
4080 NEXT
4090 ENDPROC

4200 REM Colour mapping to RGB 
4210 DATA &00, &20, &08, &28, &02, &22, &0A, &2A
4220 DATA &15, &30, &0C, &3C, &03, &33, &0F, &3F
4230 DATA &01, &04, &05, &06, &07, &09, &0B, &0D
4240 DATA &0E, &10, &11, &12, &13, &14, &16, &17
4250 DATA &18, &19, &1A, &1B, &1C, &1D, &1E, &1F
4260 DATA &21, &23, &24, &25, &26, &27, &29, &2B
4270 DATA &2C, &2D, &2E, &2F, &31, &32, &34, &35
4280 DATA &36, &37, &38, &39, &3A, &3B, &3D, &3E
4300 REM - RGB colours 
4310 DATA &00, &00, &00, &00, &00, &55, &00, &00, &AA, &00, &00, &FF
4320 DATA &00, &55, &00, &00, &55, &55, &00, &55, &AA, &00, &55, &FF
4330 DATA &00, &AA, &00, &00, &AA, &55, &00, &AA, &AA, &00, &AA, &FF
4340 DATA &00, &FF, &00, &00, &FF, &55, &00, &FF, &AA, &00, &FF, &FF
4350 DATA &55, &00, &00, &55, &00, &55, &55, &00, &AA, &55, &00, &FF
4360 DATA &55, &55, &00, &55, &55, &55, &55, &55, &AA, &55, &55, &FF
4370 DATA &55, &AA, &00, &55, &AA, &55, &55, &AA, &AA, &55, &AA, &FF
4380 DATA &55, &FF, &00, &55, &FF, &55, &55, &FF, &AA, &55, &FF, &FF
4390 DATA &AA, &00, &00, &AA, &00, &55, &AA, &00, &AA, &AA, &00, &FF
4400 DATA &AA, &55, &00, &AA, &55, &55, &AA, &55, &AA, &AA, &55, &FF
4410 DATA &AA, &AA, &00, &AA, &AA, &55, &AA, &AA, &AA, &AA, &AA, &FF
4420 DATA &AA, &FF, &00, &AA, &FF, &55, &AA, &FF, &AA, &AA, &FF, &FF
4430 DATA &FF, &00, &00, &FF, &00, &55, &FF, &00, &AA, &FF, &00, &FF
4440 DATA &FF, &55, &00, &FF, &55, &55, &FF, &55, &AA, &FF, &55, &FF
4450 DATA &FF, &AA, &00, &FF, &AA, &55, &FF, &AA, &AA, &FF, &AA, &FF
4460 DATA &FF, &FF, &00, &FF, &FF, &55, &FF, &FF, &AA, &FF, &FF, &FF

5000 REM Error Handling
5010 VDU 23, 0, 192, 1 : REM turn on normal logical screen scaling
5020 VDU 23, 1, 1 : REM enable text cursor
5030 COLOUR 15
5030 IF ISEXIT=0 PRINT:REPORT:PRINT " at line ";ERL:END
5040 PRINT "Goodbye"

