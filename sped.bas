10 REM Sprite editor
15 VERSION$="v0.6"
20 ON ERROR GOTO 5000
23 REM memory - just for file load at the moment
25 DIM graphics 1024
27 MB%=&40000
30 MODE 8
40 SW%=320 : SH%=240
50 COL%=3
60 GRIDX%=16 : GRIDY%=16 : W%=16 : H%=16
70 DIM G%(W%*H%) : FOR I%=0 TO W%*H%-1 : G%(I%)=0
75 DIM CL%(64) : DIM RGB%(64*3) : DIM REVLU%(64) : PROCloadLUT
79 REM palette x/y and sprite x/y positions on screen
80 PALX%=160 : PALY%=16 : SPX%=16 : SPY%=160
85 PX%=0 : PY%=0 : REM selected palette position
90 GRIDCOL%=8 : CURSCOL%=15 :ISEXIT=0
100 DIM KEYG(4), KEYP(4) : REM in order left, right, up down 
110 KEY_SET=32 : KEY_DEL=127 : PROCsetkeys
120 FILENAME$="" : FLINE%=24
130 PROCcreateSprite(W%,H%)
140 PROCdrawScreen
200 REM Main Loop
210 REPEAT
220 key=INKEY(0)
225 UPDATESPRITE=0
230 REM IF key > -1 PRINT TAB(0,0);"     ": PRINT TAB(0,0);key
240 REM left=8, right=21, up=11, down=10, tab=9, nums 0=48 ... 9=57
250 REM q=110, x=120, s=115, spc=32, w,a,s,d = 119,97,115,100
260 REM a=97 ... z=122, ","=44, "."=46  backspace=127 c=99
270 IF key=-1 GOTO 600 : REM skip to Until
280 PROCgridCursor(0)
290 IF key = 120 ISEXIT=1 : REM x=exit
300 REM grid cursor movement
310 IF key = KEYG(0) AND PX%>0 THEN PX%=PX%-1 : REM left
320 IF key = KEYG(1) AND PX%<15 THEN PX%=PX%+1 : REM right
330 IF key = KEYG(2) AND PY%>0 THEN PY%=PY%-1 : REM up
340 IF key = KEYG(3) AND PY%<15 THEN PY%=PY%+1 : REM down
350 REM colour select movement
360 IF key = KEYP(0) AND COL%>15 THEN PROCselectPaletteCol(COL%-16) : REM left
370 IF key = KEYP(1) AND COL%<47 THEN PROCselectPaletteCol(COL%+16) : REM right
380 IF key = KEYP(2) AND COL%>0 THEN PROCselectPaletteCol(COL%-1) : REM up
390 IF key = KEYP(3) AND COL%<63 THEN PROCselectPaletteCol(COL%+1) : REM down
400 REM space = set colour, backspace = delete (set to 0), f=fill to current col
410 IF key = 32 THEN PROCsetCol(PX%,PY%,COL%) : UPDATESPRITE=1
420 IF key = 127 THEN PROCsetCol(PX%,PY%,0) : UPDATESPRITE=1
430 IF key = 99 THEN PROCclearGrid(0) : UPDATESPRITE=1
440 IF key = 102 THEN PROCclearGrid(COL%) : UPDATESPRITE=1
450 REM V=save L=load
460 IF key = 118 THEN PROCsaveFile : REM V=saVe file 
470 IF key = 108 THEN PROCloadFile
480 PROCprintColour(27,2)
490 IF UPDATESPRITE=1 THEN PROCshowSprite
500 PROCgridCursor(1)
600 UNTIL ISEXIT = 1
610 GOTO 5000

698 :
699 STOP

700 DEF PROCdrawScreen
710 REM draw screen - titles, instructions.
720 VDU 23,0,192,0 : REM turn off logical screen scaling
730 VDU 23, 1, 0 : REM disable text cursor
740 PROCdrawGrid(W%,H%,GRIDX%,GRIDY%)
750 PROCdrawPalette(PALX%,PALY%)
760 PROCselectPaletteCol(1)
770 PROCprintColour(27,2)
780 PROCgridCursor(1)
790 PROCrect(SPX%-2, SPY%-2, W%+3, H%+3, GRIDCOL%)
800 COLOUR 54:PRINT TAB(0,0);"SPRITE EDITOR";
810 COLOUR 20:PRINT TAB(14,0);"for the Agon ";
814 COLOUR 8:PRINT TAB(27,0);VERSION$;
816 COLOUR 26:PRINT TAB(32,0);"by Assif";
820 GCOL 0,15 : MOVE 0,10 : DRAW 320,10
830 GCOL 0,15 : MOVE 0,26*8-4 : DRAW 320,26*8-4
840 COLOUR 21 : PRINT TAB(0,26);"Cursor"; :COLOUR 19:PRINT TAB(7,26);"Move";
850 COLOUR 21 : PRINT TAB(0,27);"WASD  "; :COLOUR 19:PRINT TAB(7,27);"Select col";
860 COLOUR 21 : PRINT TAB(0 ,28);"Space"; :COLOUR 19:PRINT TAB(7,28);"Set";
870 COLOUR 21 : PRINT TAB(0, 29);"Backsp";:COLOUR 19:PRINT TAB(7,29);"Unset";
880 COLOUR 21 : PRINT TAB(18,28);"F";     :COLOUR 19:PRINT TAB(21,28);"Fill";
890 COLOUR 21 : PRINT TAB(18,29);"C";     :COLOUR 19:PRINT TAB(21,29);"Clear";
900 COLOUR 21 : PRINT TAB(30,26);"X";     :COLOUR 19:PRINT TAB(33,26);"Exit";
910 COLOUR 21 : PRINT TAB(30,28);"V";     :COLOUR 19:PRINT TAB(33,28);"Save";
920 COLOUR 21 : PRINT TAB(30,29);"L";     :COLOUR 19:PRINT TAB(33,29);"Load";
930 PROCshowFilename
980 COLOUR 15
990 ENDPROC

1000 DEF PROCdrawGrid(w%,h%,x%,y%)
1010 REM drawgrid in GRIDCOL%
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

1200 DEF PROCdrawPalette(x%,y%)
1210 REM draw palette colours - 4 cols of 16
1220 FOR N%=0 TO 3
1230 FOR I%=0 TO 15
1240 PROCfilledRect(1+x%+N%*10,1+y%+I%*10,6,6,I%+N%*16)
1250 NEXT I%
1260 NEXT N%
1270 ENDPROC

1300 DEF PROCselectPaletteCol(c%)
1310 REM select colour in palette - move the white select box
1320 x% = COL% DIV 16 : y% = COL% MOD 16
1330 PROCrect(PALX%+x%*10, PALY%+y%*10, 8, 8, 0)
1340 COL%=c%
1350 x% = COL% DIV 16 : y% = COL% MOD 16
1360 PROCrect(PALX%+x%*10, PALY%+y%*10, 8, 8, 15)
1370 ENDPROC

1400 REM draw gridcursor
1410 DEF PROCgridCursor(switch%)
1420 col%=GRIDCOL% : REM off
1430 IF switch%=1 THEN col%=CURSCOL% : REM on
1440 PROCrect(GRIDX%+PX%*8, GRIDY%+PY%*8, 8, 8, col%)
1490 ENDPROC

1500 REM set colour in grid
1510 DEF PROCsetCol(x%,y%,c%)
1520 G%(x%+y%*W%)=c%
1530 PROCfilledRect(1+GRIDX%+x%*8, 1+GRIDY%+y%*8, 6, 6, c%)
1590 ENDPROC

1600 DEF PROCclearGrid(col%)
1610 REM clear grid to a colour
1620 FOR i%=0 TO W%-1
1630 FOR j%=0 TO H%-1
1640 G%(i%+j%*W%)=col%
1650 NEXT 
1660 NEXT
1670 PROCfilledRect(GRIDX%,GRIDY%, W%*8,H%*8,col%)
1680 PROCdrawGrid(W%,H%,GRIDX%,GRIDY%)
1690 ENDPROC

1700 DEF PROCcreateSprite(w,h)
1710 REM setup the sprite and bitmap
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

1800 DEF PROCshowSprite
1810 REM show sprite
1814 REM currently copies all data from grid to sprite
1815 REM this is slow - TODO do this in Z80 asm to speed up
1820 VDU 23,27,0,0: REM Select bitmap 0
1825 VDU 23,27,1,W%;H%;
1830 FOR I%=0 TO W%*H%-1
1840 clu%=CL%(G%(I%))
1850 VDU RGB%(clu%*3), RGB%(clu%*3+1), RGB%(clu%*3+2), 255
1870 NEXT
1880 VDU 23,27,4,0,23,27,13,SPX%; SPY%;
1890 ENDPROC

1900 DEF PROCprintColour(x%,y%)
1910 REM print colour
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
2010 REM set the keys used for movment. Put in proc for future customisation opts
2020 REM arrows left=8, right=21, up=11, down=10
2035 REM w,a,s,d = w=119(up),a=97(left),s=115(down),d=100(right)
2030 KEYG(0)=8 : KEYG(1)=21 : KEYG(2)=11 : KEYG(3)=10 
2040 KEYP(0)=97 : KEYP(1)=100 : KEYP(2)=119 : KEYP(3)=115 
2090 ENDPROC

2100 DEF PROCsaveFile
2105 REM ask for a filename and save the data in RGB raw format with no headers
2110 PROCgetSaveFilename
2120 FHAN%=OPENOUT(FILENAME$)
2130 REM need an exists/overwrite dialog ...
2140 REM IF FHAN% > 0 THEN .... 
2150 PROCsaveDataFile(FHAN%)
2190 ENDPROC

2200 DEF PROCgetSaveFilename
2205 REM ask for a filename
2210 PRINT TAB(0,FLINE%);SPC(39);
2220 COLOUR 31 : PRINT TAB(0,FLINE%);"Enter filename:";
2230 COLOUR 15 : INPUT FILENAME$;
2240 PROCshowFilename
2290 ENDPROC

2300 DEF PROCloadFile
2305 REM ask for a filename, and call load routine 
2310 PRINT TAB(0,FLINE%);SPC(39);
2320 COLOUR 31 : PRINT TAB(0,FLINE%);"Enter filename:";
2330 COLOUR 15 : INPUT FILENAME$;
2340 FHAN%=OPENIN(FILENAME$)
2350 IF FHAN% = 0 THEN COLOUR 1:PRINT TAB(30,FLINE%);"No file"; :FILENAME$="": ENDPROC
2360 FLEN%=EXT#FHAN% : IF FLEN%<>768 THEN COLOUR 1:PRINT TAB(30,FLINE%);"Not valid";:FILENAME$="": CLOSE#FHAN%: ENDPROC
2370 CLOSE#FHAN% : PROCloadDataFile(FHAN%)
2390 ENDPROC

2400 DEF PROCshowFilename
2405 REM just display filename in status bar
2410 GCOL 0,15 : MOVE 0,FLINE%*8-4 : DRAW 320,FLINE%*8-4
2420 PRINT TAB(0,FLINE%);SPC(39);
2430 COLOUR 31 : PRINT TAB(0,FLINE%);"FILE:";TAB(6,FLINE%);FILENAME$;
2490 ENDPROC

2500 DEF PROCloadDataFile(h%)
2501 REM this loads file to internal memory and copies it out to the sprite
2505 OSCLI("LOAD " + FILENAME$ + " " + STR$(MB%+graphics))
2510 FOR I%=0 TO (W%*H%)-1
2520 DATR% = ?(graphics+I%*3+0) DIV 85
2530 DATG% = ?(graphics+I%*3+1) DIV 85
2540 DATB% = ?(graphics+I%*3+2) DIV 85
2550 IND% = DATR% * 16 + DATG% * 4 + DATB% : REM RGB colour as index
2560 col% = REVLU%(IND%) : REM Reverse lookup of RGB colour to BBC Colour code
2570 G%(I%) = col% : x%=I% MOD W% : y%=I% DIV W%
2580 PROCfilledRect(1+GRIDX%+x%*8, 1+GRIDY%+y%*8, 6, 6, col%)
2590 NEXT I%
2600 PROCdrawGrid(W%,H%,GRIDX%,GRIDY%)
2610 PROCshowSprite
2690 ENDPROC

2700 DEF PROCsaveDataFile(h%)
2705 REM save raw data to a file. RGB format with no header.
2710 FOR I%=0 TO (W%*H%)-1
2720 RGBIndex% = CL%(G%(I%)) : REM lookup the RGB colour index for this colour 
2730 BPUT#h%, RGB%(RGBIndex%*3)
2740 BPUT#h%, RGB%(RGBIndex%*3+1)
2750 BPUT#h%, RGB%(RGBIndex%*3+2)
2760 NEXT
2770 CLOSE#h%
2790 ENDPROC

3000 DEF PROCfilledRect(x%,y%,w%,h%,c%)
3010 REM PROCfilledRect draw a filled rectangle
3011 REM assume screen scaling OFF
3012 REM update for basic 3.00, use 85 to plot a triangle, or 101 to plot a filled rect
3020 GCOL 0,c%
3030 MOVE x%,y% 
3040 REM MOVE x%+w%,y% : PLOT 85, x%+w%, y%+h%
3050 REM MOVE x%, y%+h% : PLOT 85, x%, y%
3055 PLOT 101, x%+w%, y%+h%
3060 ENDPROC

3100 DEF PROCrect(x%,y%,w%,h%,c%)
3110 REM PROCrect draw a rectangle. assume screen scaling is OFF
3120 GCOL 0,c%
3130 MOVE x%,y% 
3140 DRAW x%+w%,y% 
3150 DRAW x%+w%, y%+h%
3160 DRAW x%, y%+h% 
3170 DRAW x%, y%
3180 ENDPROC

4000 DEF PROCloadLUT
4010 REM Load the RGB Look up table
4011 REM CL%() is BBC Col to RGBIndex
4012 REM RGB%() is a packed array of the RGB colours
4013 REM REVLU%() is a reverse lookup table to get the colour  
4025 RESTORE
4030 FOR I%=0 TO 63 
4040 READ CL%(I%)
4050 NEXT
4060 FOR I%=0 TO 63
4070 READ RGB%(I%*3),RGB%(I%*3+1),RGB%(I%*3+2),REVLU%(I%)
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
4300 REM - RGB colours with a reverse map
4310 DATA &00, &00, &00,  0, &00, &00, &55, 16, &00, &00, &AA,  4, &00, &00, &FF, 12
4320 DATA &00, &55, &00, 17, &00, &55, &55, 18, &00, &55, &AA, 19, &00, &55, &FF, 20
4330 DATA &00, &AA, &00,  2, &00, &AA, &55, 21, &00, &AA, &AA,  6, &00, &AA, &FF, 22
4340 DATA &00, &FF, &00, 10, &00, &FF, &55, 23, &00, &FF, &AA, 24, &00, &FF, &FF, 14
4350 DATA &55, &00, &00, 25, &55, &00, &55, 26, &55, &00, &AA, 27, &55, &00, &FF, 28
4360 DATA &55, &55, &00, 29, &55, &55, &55,  8, &55, &55, &AA, 30, &55, &55, &FF, 31
4370 DATA &55, &AA, &00, 32, &55, &AA, &55, 33, &55, &AA, &AA, 34, &55, &AA, &FF, 35
4380 DATA &55, &FF, &00, 36, &55, &FF, &55, 37, &55, &FF, &AA, 38, &55, &FF, &FF, 39
4390 DATA &AA, &00, &00,  1, &AA, &00, &55, 40, &AA, &00, &AA,  5, &AA, &00, &FF, 41
4400 DATA &AA, &55, &00, 42, &AA, &55, &55, 43, &AA, &55, &AA, 44, &AA, &55, &FF, 45
4410 DATA &AA, &AA, &00,  3, &AA, &AA, &55, 46, &AA, &AA, &AA,  7, &AA, &AA, &FF, 47
4420 DATA &AA, &FF, &00, 48, &AA, &FF, &55, 49, &AA, &FF, &AA, 50, &AA, &FF, &FF, 51
4430 DATA &FF, &00, &00,  9, &FF, &00, &55, 52, &FF, &00, &AA, 53, &FF, &00, &FF, 13
4440 DATA &FF, &55, &00, 54, &FF, &55, &55, 55, &FF, &55, &AA, 56, &FF, &55, &FF, 57
4450 DATA &FF, &AA, &00, 58, &FF, &AA, &55, 59, &FF, &AA, &AA, 60, &FF, &AA, &FF, 61
4460 DATA &FF, &FF, &00, 11, &FF, &FF, &55, 62, &FF, &FF, &AA, 63, &FF, &FF, &FF, 15

5000 REM Error Handling
5010 VDU 23, 0, 192, 1 : REM turn on normal logical screen scaling
5020 VDU 23, 1, 1 : REM enable text cursor
5030 COLOUR 15
5030 IF ISEXIT=0 PRINT:REPORT:PRINT " at line ";ERL:END
5040 PRINT "Goodbye"

