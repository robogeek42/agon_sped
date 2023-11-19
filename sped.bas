10 REM Sprite editor for the Agon Light and Console 8 by Assif (robogeekoid)
11 REM NOTE: Requires VDP version 2.0.0+ for the bitmap backed sprite function
12 REM Thanks to discord user eightbitswide for the joystick code
15 VERSION$="v0.13"
20 ON ERROR GOTO 10000
25 DIM graphics 1024 : REM memory for file load 
27 MB%=&40000 
30 MODE 8
35 ISEXIT=0 : SW%=320 : SH%=240 
37 REM ----- config in sped.ini -----
40 CONFIG_SIZE=1 : CONFIG_JOY=0 : CONFIG_TYPE=0
42 CONFIG_JOYDELAY=20
50 PROCconfig("sped.ini")
52 IF CONFIG_SIZE=2 THEN W%=8 : H%=8 ELSE W%=16 : H%=16
55 REM --------------------------------
57 GRIDX%=8 : GRIDY%=16 : REM Grid position
60 GRIDCOL%=8 : CURSCOL%=15
65 SCBOXX%=170 : SCBOXY%=148 : REM shortcut box pos
70 DIM CL%(64) : DIM RGB%(64*3) : DIM REVLU%(64) : PROCloadLUT
75 DIM BSTAB%(3,3) : PROCloadBitshiftTable

80 PALX%=8 : PALY%=146 : PALW%=16 : PALH%=4 : REM palette x/y,w/h 
85 PX%=0 : PY%=0 : COL%=1 : REM selected palette colour

100 DIM KEYG(4), KEYP(4) : REM in order left, right, up down 
105 KEY_SET=32 : KEY_DEL=127 : PROCsetkeys
110 FLINE%=24 : REM FLINE is line on which filename appears
115 F$=STRING$(20," ") 
120 DIM SKey%(9) : FOR I%=0 TO 9 : SKey%=-1 : NEXT I%

130 REM multi-bitmap sprite setup
135 NumBitmaps% = 6 : BM% = 0 : REM current bitmap
140 NSF% = 3 : SF%=0 : REM Number of sprite frames and current frame
145 Delay%=10 : Ctr%=Delay%

150 REM Calc positions of sprite frame frames
155 SPX%=150 : SPY%=18 : REM sprite x/y position on screen
157 BBOXX%=150 : BBOXY%=42 : REM top-left of bitmap boxes
160 DIM BMX%(NumBitmaps%), BMY%(NumBitmaps%)
165 FOR I%=0 TO NumBitmaps%-1 : BMX%(I%)=BBOXX% + 24*I% : BMY%(I%)=BBOXY% : NEXT

170 REM declare data for grid
175 DIM G%(W%*H%, NumBitmaps%) 

180 PROCdrawScreen
182 COLOR 15 : PRINT TAB(18,13);"LOADING";
185 PROCcreateSprite(W%,H%)

190 FOR B%=0 TO NumBitmaps%-1
195 FOR I%=0 TO W%*H%-1 : G%(I%, B%)=0 : NEXT I%
200 NEXT B%

210 FOR B%=0 TO NumBitmaps%-1 : PROCupdateBitmapFromGrid(B%) : NEXT
220 REM PROCupdateScreenGrid(BM%)

230 COLOR 15 : PRINT TAB(18,13);"       ";

240 REM Main Loop
250 REPEAT
260 key=INKEY(0)
265 IF CONFIG_JOY=1 JOY=GET(158) : BUTTON=GET(162) ELSE JOY=0 : BUTTON=0
267 IF CONFIG_JOY=0 AND key=-1 GOTO 600
270 IF key=-1 AND JOY=255 AND BUTTON=247 GOTO 600 : REM skip to Until
280 PROCgridCursor(0)
290 IF key = 120 OR key=120-32 ISEXIT=1 : REM x=exit
295 IF ISEXIT=1 THEN yn$=FNinputStr("Are you sure (y/N)"): IF yn$<>"Y" AND yn$<>"y" THEN ISEXIT=0
300 REM grid cursor movement
310 IF key = KEYG(0) AND PX%>0 THEN PX%=PX%-1 : REM left
320 IF key = KEYG(1) AND PX%<(W%-1) THEN PX%=PX%+1 : REM right
330 IF key = KEYG(2) AND PY%>0 THEN PY%=PY%-1 : REM up
340 IF key = KEYG(3) AND PY%<(H%-1) THEN PY%=PY%+1 : REM down
341 REM joystick movement 
342 IF JOY>0 AND (JOY AND 223)=JOY AND PX%>0 THEN PX%=PX%-1 : TIME=0: REPEATUNTILTIME>CONFIG_JOYDELAY : REM LEFT
343 IF JOY>0 AND (JOY AND 127)=JOY AND PX%<(W%-1) THEN PX%=PX%+1 : TIME=0: REPEATUNTILTIME>CONFIG_JOYDELAY : REM RIGHT
344 IF JOY>0 AND (JOY AND 253)=JOY AND PY%>0 THEN PY%=PY%-1 : TIME=0 : REPEATUNTILTIME>CONFIG_JOYDELAY : REM UP
345 IF JOY>0 AND (JOY AND 247)=JOY AND PY%<(H%-1) THEN PY%=PY%+1 : TIME=0 : REPEATUNTILTIME>CONFIG_JOYDELAY :REM DOWN
350 REM colour select movement
360 IF (key = KEYP(0) OR key=KEYP(0)-32) AND COL%>0 THEN PROCselectPaletteCol(COL%-1) : REM left
370 IF (key = KEYP(1) OR key=KEYP(1)-32) AND COL%<63 THEN PROCselectPaletteCol(COL%+1) : REM right
380 IF (key = KEYP(2) OR key=KEYP(2)-32) AND COL%>(PALW%-1) THEN PROCselectPaletteCol(COL%-PALW%) : REM up
390 IF (key = KEYP(3) OR key=KEYP(3)-32) AND COL%<(63-PALW%) THEN PROCselectPaletteCol(COL%+PALW%) : REM down
400 REM space = set colour, backspace = delete (set to 0), f=fill to current col
410 IF key = 32 THEN PROCsetCol(PX%,PY%,COL%)
415 IF BUTTON=215 THEN PROCsetCol(PX%,PY%,COL%)
420 IF key = 127 OR key=127-32 THEN PROCsetCol(PX%,PY%,0)
430 IF key = 99 OR key=99-32 THEN PROCclearGrid(0, BM%)
440 IF key = 102 OR key=102-32 THEN PROCclearGrid(COL%, BM%)
450 IF key = 112 OR key=112-32 THEN PROCpickCol
460 REM V=save L=load
470 IF key = 118 OR key=118-32 THEN PROCloadSaveFile(1) : REM V=saVe file 
480 IF key = 108 OR key=108-32 THEN PROCloadSaveFile(0)
490 IF key = 109 OR key=109-32 THEN BM%=(BM%+1) MOD NumBitmaps% : PROCdrawBitmapBoxes : PROCupdateScreenGrid(BM%)
500 IF key = 110 OR key=110-32 THEN BM%=(BM%-1) : IF BM%<0 THEN BM%=NumBitmaps%-1
510 IF key = 110 OR key=110-32 THEN PROCdrawBitmapBoxes : PROCupdateScreenGrid(BM%)
520 IF key = 107 OR key=107-32 THEN PROCsetShortcutKey
530 IF key >=49 AND key <=57 THEN IF SKey%(key-48)>=0 THEN PROCselectPaletteCol(SKey%(key-48))
540 IF key = 114 OR key = 114-32 THEN PROCsetFrames
550 IF key = 101 OR key = 101-32 THEN PROCexport
560 PROCshowFilename("")
580 PROCgridCursor(1)

600 REM Nokey GOTO comes here
610 PROCshowSprite
620 UNTIL ISEXIT = 1
630 GOTO 10000

695 END

699 REM ------ Static Screen Update Functions ---------------

700 DEF PROCprintTitle
705 COLOUR 54:PRINT TAB(0,0);"SPRITE EDITOR";
710 COLOUR 20:PRINT TAB(14,0);"for the Agon ";
715 COLOUR 8:PRINT TAB(35,0);VERSION$;
720 GCOL 0,15 : MOVE 0,10 : DRAW 320,10
730 ENDPROC

750 DEF PROCdrawScreen
751 REM draw screen - titles, instructions.
755 LOCAL I%
760 CLS : VDU 23,0,192,0 : REM turn off logical screen scaling
765 VDU 23, 1, 0 : REM disable text cursor
770 PROCdrawGrid(W%,H%,GRIDX%,GRIDY%)
772 PROCdrawPalette(PALX%,PALY%)
774 PROCselectPaletteCol(COL%)
776 PROCgridCursor(1)
778 PROCdrawBitmapBoxes
780 PROCprintTitle
782 PROCprintHelp
784 PROCshowFilename("")
786 COLOUR 15
790 ENDPROC

800 DEF PROCprintHelp
810 GCOL 0,15 : MOVE 0,26*8-4 : DRAW 320,26*8-4
820 COLOUR 21 : PRINT TAB(0,26);"Cursor"; :COLOUR 19:PRINT TAB(7,26);"Move";
830 COLOUR 21 : PRINT TAB(0,27);"WASD  "; :COLOUR 19:PRINT TAB(7,27);"Colour";
840 COLOUR 21 : PRINT TAB(0 ,28);"Space"; :COLOUR 19:PRINT TAB(7,28);"Set";
850 COLOUR 21 : PRINT TAB(0, 29);"Backsp";:COLOUR 19:PRINT TAB(7,29);"Unset";
860 COLOUR 21 : PRINT TAB(16,27);"P";     :COLOUR 19:PRINT TAB(21,27);"Pick";
870 COLOUR 21 : PRINT TAB(16,28);"F";     :COLOUR 19:PRINT TAB(21,28);"Fill";
880 COLOUR 21 : PRINT TAB(16,29);"C";     :COLOUR 19:PRINT TAB(21,29);"Clear";
890 COLOUR 21 : PRINT TAB(30,26);"X";     :COLOUR 19:PRINT TAB(33,26);"eXit";
900 COLOUR 21 : PRINT TAB(30,27);"V";     :COLOUR 19:PRINT TAB(33,27);"saVe";
910 COLOUR 21 : PRINT TAB(30,28);"L";     :COLOUR 19:PRINT TAB(33,28);"Load";
920 COLOUR 21 : PRINT TAB(30,29);"E";     :COLOUR 19:PRINT TAB(33,29);"Export";
930 COLOUR 7 : FOR I%=1 TO 9 : PRINT TAB((SCBOXX% DIV 8) -1 +I%*2,SCBOXY% DIV 8 +1 );I% : NEXT
940 COLOUR 8 : PRINT TAB((SCBOXX% DIV 8) +1,SCBOXY% DIV 8 +4);"Shortcut K=set";
950 PROCrect(SCBOXX%, SCBOXY%-2,16*9,39,7)
960 COLOUR 21 : PRINT TAB(19,10);"N M";   :COLOUR 19:PRINT TAB(23,10);"Select Bitmap";
970 COLOUR 21 : PRINT TAB(19,11);"R";     :COLOUR 19:PRINT TAB(23,11);"Num Frames";
980 ENDPROC

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

1100 DEF PROCdrawBitmapBoxes
1105 REM bitmap boxes, highlight selected
1110 FOR S%=0 TO NumBitmaps%-1
1120 IF S% = BM% THEN gc%=CURSCOL% ELSE gc%=GRIDCOL%
1130 PROCrect(BMX%(S%)-2, BMY%(S%)-2, W%+3, H%+3, gc%)
1135 IF S% < NSF% THEN COLOUR 1 ELSE COLOUR 8
1140 PRINT TAB(1+(BBOXX% DIV 8) + 3*S%, BBOXY% DIV 8 + 3);S%+1;
1150 NEXT
1155 ENDPROC

1160 DEF PROCsetkeys
1161 REM set the keys used for movment. Put in proc for future customisation opts
1170 KEYG(0)=8 : KEYG(1)=21 : KEYG(2)=11 : KEYG(3)=10 
1180 KEYP(0)=97 : KEYP(1)=100 : KEYP(2)=119 : KEYP(3)=115 
1190 ENDPROC

1200 DEF PROCdrawPalette(x%,y%)
1205 REM draw palette colours - I% across, J% down
1210 LOCAL I%,J%, C%
1215 C%=0
1220 FOR J%=0 TO PALH%-1
1230 FOR I%=0 TO PALW%-1
1240 PROCfilledRect(1+x%+I%*10,1+y%+J%*10,6,6,C%)
1245 C%=C%+1
1250 NEXT I%
1260 NEXT J%
1270 ENDPROC

1300 DEF PROCselectPaletteCol(c%)
1310 REM select colour in palette - move the white select box
1315 REM unselect previous colour
1320 x% = COL% MOD PALW% : y% = COL% DIV PALW% : REM horizontal
1330 PROCrect(PALX%+x%*10, PALY%+y%*10, 8, 8, 0)
1335 REM select new colour
1340 COL%=c%
1350 x% = COL% MOD PALW% : y% = COL% DIV PALW% : REM horizontal
1360 PROCrect(PALX%+x%*10, PALY%+y%*10, 8, 8, 15)
1365 PROCprintColour(27,2)
1370 ENDPROC

1400 DEF PROCpickCol
1410 LOCAL col%
1420 col% = G%(PX%+PY%*W%, BM%)
1430 PROCselectPaletteCol(col%)
1440 ENDPROC

1450 DEF PROCgridCursor(switch%)
1455 REM draw gridcursor
1460 LOCAL col%
1470 col%=GRIDCOL% : REM off
1480 IF switch%=1 THEN col%=CURSCOL% : REM on
1490 PROCrect(GRIDX%+PX%*8, GRIDY%+PY%*8, 8, 8, col%)
1495 ENDPROC

1500 DEF PROCprintColour(x%,y%)
1505 REM print colour
1510 LOCAL clu%
1520 clu%=CL%(COL%)
1530 PRINT TAB(x%,y%);SPC(6); 
1540 COLOUR 15: PRINT TAB(x%,y%);"COL ";COL%;
1565 REM hex
1570 COLOUR 9 : PRINT TAB(x%+7,y%);"00";
1572 COLOUR 9 : PRINT TAB(x%+7,y%);~RGB%(clu%*3);
1575 COLOUR 10: PRINT TAB(x%+9,y%);"00";
1577 COLOUR 10: PRINT TAB(x%+9,y%);~RGB%(1+clu%*3);
1580 COLOUR 12: PRINT TAB(x%+11,y%);"00";
1582 COLOUR 12: PRINT TAB(x%+11,y%);~RGB%(2+clu%*3);
1585 COLOUR 15
1590 ENDPROC

1599 REM ------ Grid/Bitmap Update Functions -----------------
1600 :
1602 REM SCREEN Grid      DATA Grid       Bitmap      Sprite 
1604 REM   SetCol    -->    update   -->  update -->  refresh
1605 REM   update    <--  Load/Clear -->  update -->  refresh

1650 DEF PROCsetCol(x%,y%,c%)
1655 REM set colour in screen grid AND Data Grid G%
1660 G%(x%+y%*W%, BM%)=c%
1670 PROCfilledRect(1+GRIDX%+x%*8, 1+GRIDY%+y%*8, 6, 6, c%)
1680 PROCupdateBitmapPixel(BM%, x%, y%, c%)
1690 ENDPROC

1700 DEF PROCclearGrid(col%, bmap%)
1701 REM clear grid to a colour (Screen and Data Grids)
1702 REM update of bitmap must be done separately
1710 LOCAL i%, j%
1720 FOR i%=0 TO W%-1
1725 FOR j%=0 TO H%-1
1730 G%(i%+j%*W%, bmap%)=col%
1735 NEXT j%
1740 NEXT i%
1745 REM fast clear all cells
1750 PROCfilledRect(GRIDX%,GRIDY%, W%*8,H%*8,col%)
1760 PROCdrawGrid(W%,H%,GRIDX%,GRIDY%)
1770 PROCupdateBitmapFromGrid(bmap%)
1790 ENDPROC

1800 DEF PROCupdateScreenGrid(bmap%)
1801 REM Update the screen grid from data grid G%() for given bitmap
1805 LOCAL col%
1810 FOR I%=0 TO W%*H%-1
1820 col%=G%(I%, bmap%) 
1830 x%=I% MOD W% : y%=I% DIV W%
1840 PROCfilledRect(1+GRIDX%+x%*8, 1+GRIDY%+y%*8, 6, 6, col%)
1850 NEXT I%
1890 ENDPROC

1900 DEF PROCupdateBitmapFromGrid(bmap%)
1905 REM update bitmap from its data drid
1906 REM TODO speed up - use memory and precomputed lookup?
1910 LOCAL clu%
1920 VDU 23,27,0,bmap%   : REM Select bitmap n
1924 REM Use Adjust Buffer API
1925 VDU 23,0,&A0,bmap%+&FA00;5,&C2,0;W%*H%*4;
1930 FOR I%=0 TO W%*H%-1
1935 clu%=CL%(G%(I%, bmap%))     : REM lookup RGB index
1940 VDU RGB%(clu%*3), RGB%(clu%*3+1), RGB%(clu%*3+2), 255
1945 NEXT
1950 PROCupdateSpriteBitmap(bmap%)
1990 ENDPROC

2000 DEF PROCupdateBitmapPixel(bmap%, x%, y%, c%)
2005 REM update a single bitmap pixel
2010 LOCAL clu%
2020 VDU 23,27,0,bmap%   : REM Select bitmap n
2025 REM Use Adjust Buffer API
2030 VDU 23,0,&A0,bmap%+&FA00;5,&C2,(x%+y%*W%)*4;4;
2040 clu%=CL%(c%)     : REM lookup RGB index
2050 VDU RGB%(clu%*3), RGB%(clu%*3+1), RGB%(clu%*3+2), 255
2060 PROCupdateSpriteBitmap(bmap%)
2090 ENDPROC

2099 REM ------ Sprite Functions -----------------------------

2100 DEF PROCcreateSprite(w%,h%)
2102 REM setup the sprite and bitmap. Clear both grids
2105 LOCAL B%
2110 FOR B%=0 TO NumBitmaps%-1
2115 VDU 23,27,0,B%       : REM Select bitmap bmnum%
2120 VDU 23,27,2,w%;h%;&FFFF;&FFFF; : REM create empty (black) bitmap
2125 NEXT B%
2130 VDU 23,27,4,0        : REM Select sprite 0
2135 VDU 23,27,5          : REM Clear frames for current sprite
2140 FOR B%=0 TO NumBitmaps%-1
2145 VDU 23,27,6,B%       : REM Add bitmap n as a frame of sprite
2150 NEXT B%
2160 VDU 23,27,11         : REM Show the sprite
2165 VDU 23,27,7,1        : REM activate 1 sprite
2170 VDU 23,27,13,SPX%; SPY%; : REM display sprite
2190 ENDPROC

2200 DEF PROCupdateSpriteBitmap(bmap%)
2205 REM display bitmap and update sprite with bitmap
2206 VDU 23,27,0,bmap%
2210 VDU 23,27,3,BMX%(bmap%);BMY%(bmap%); : REM draw bitmap
2240 VDU 23,27,15: REM Refresh the sprites
2290 ENDPROC

2300 DEF PROCshowSprite
2305 REM show sprite animation
2307 REM update frame number every Delay% screen refreshes
2310 Ctr% = Ctr% - 1
2320 IF Ctr%=0 THEN Ctr%=Delay% : SF%=SF%+1 : IF SF%=NSF% THEN SF%=0
2330 VDU 23,27,10,SF% : REM select frame
2340 *FX 19 : REM wait for refresh
2345 VDU 23,27,15 : REM update sprites
2390 ENDPROC 

2399 REM ------ Set shortcut keys, Frames etc. ----------------

2400 DEF PROCsetShortcutKey
2410 K = FNinputInt("Shortcut (1-9):")
2430 IF K >= 1 AND K <= 9 THEN SKey%(K) = COL% :  PROCfilledRect(SCBOXX%+K*16-10,SCBOXY%+14,6,6,COL%)
2490 ENDPROC

2500 DEF PROCsetFrames
2510 K = FNinputInt("Num Frames to Show:")
2530 IF K >= 1 AND K <= NumBitmaps% THEN NSF%=K : SF%=0
2540 PROCdrawBitmapBoxes
2550 ENDPROC

2999 REM ------ File Handling --------------------------------

3000 DEF PROCshowFilename(fn$)
3005 REM just display filename in status bar
3010 GCOL 0,15 : MOVE 0,FLINE%*8-4 : DRAW 320,FLINE%*8-4
3020 PRINT TAB(0,FLINE%);SPC(40);
3030 COLOUR 31 : PRINT TAB(0,FLINE%);"FILE:";TAB(6,FLINE%);fn$;
3090 ENDPROC

3100 DEF PROCloadSaveFile(SV%)
3105 REM ask for a filename and load/save the data in RGB raw format with no headers
3106 REM ask if they want to load/save multiple frames
3110 fmt% = FNinputInt("Format 1)RGB888 2)RGBA8888 3)RGBA2222")
3120 IF fmt%<1 OR fmt%>3 THEN ENDPROC
3130 yn$ = FNinputStr("Multiple Frames (y/N)")
3140 IF yn$ = "y" OR yn$ = "Y" THEN PROCmultiple(0, fmt%) : ENDPROC
3150 F$ = FNinputStr("Enter filename:")
3160 IF SV%=1 THEN PROCsaveDataFile(F$, BM%, fmt%) ELSE PROCloadDataFile(F$, BM%, fmt%)
3170 PROCshowFilename(F$)
3190 ENDPROC

3200 DEF PROCmultiple(SV%, fmt%)
3205 LOCAL Prefix$, NumFrames%, N%
3210 Prefix$ = FNinputStr("Enter prefix:")
3220 NumFrames% = FNinputInt("Enter num frames:")
3240 IF NumFrames% <1 OR NumFrames% > NumBitmaps% THEN COLOUR 1 : PRINT TAB(32,FLINE%);"Invalid" : ENDPROC
3250 FOR N%=0 TO NumFrames%-1
3255 @%=&01000202
3260 F$ = Prefix$ + STR$(N%) + ".rgb"
3265 @%=&90A
3270 COLOUR 7 : PRINT TAB(22,FLINE%);F$;
3275 IF SV%=1 THEN PROCsaveDataFile(F$, N%, fmt%) ELSE PROCloadDataFile(F$, N%, fmt%)
3280 NEXT N%
3284 BM%=0 : PROCdrawBitmapBoxes
3286 IF SV%=0 THEN BM%=0 : PROCupdateScreenGrid(BM%) : NSF%=NumFrames% : SF%=0 : PROCdrawBitmapBoxes
3290 ENDPROC 

3300 DEF PROCloadDataFile(f$, b%, fmt%)
3301 REM this loads file to internal memory and copies it out to the sprite
3302 LOCAL col%, I%, IND%
3305 PROCshowFilename(f$)
3310 FHAN%=OPENIN(f$)
3315 IF FHAN% = 0 THEN COLOUR 1:PRINT TAB(32,FLINE%);"No file"; : ENDPROC
3320 IF fmt%=1 sz%=(W%*H%*3)
3321 IF fmt%=2 sz%=(W%*H%*4)
3322 IF fmt%=3 sz%=(W%*H%*1)
3325 FLEN%=EXT#FHAN% : IF FLEN%<>sz% THEN COLOUR 1:PRINT TAB(32,FLINE%);"Invalid";: CLOSE#FHAN%: ENDPROC
3330 COLOUR 10:PRINT TAB(36,FLINE%);"ok";
3335 CLOSE#FHAN%
3340 LSTR$="LOAD " + f$ + " " + STR$(MB%+graphics)
3345 OSCLI(LSTR$) : PRINT TAB(24,FLINE%);"LOADED";
3350 IF fmt%=1 THEN PROCloadDataFile8bit(f$, b%, 0)
3355 IF fmt%=2 THEN PROCloadDataFile8bit(f$, b%, 1)
3360 IF fmt%=3 THEN PROCloadDataFile2bit(f$, b%)
3365 PRINT TAB(24,FLINE%);"COPIED";
3370 PROCdrawGrid(W%,H%,GRIDX%,GRIDY%)
3380 PROCupdateBitmapFromGrid(b%)
3390 ENDPROC

3400 DEF PROCloadDataFile8bit(f$, b%, alpha%)
3405 IF alpha%=1 THEN datw%=4 ELSE datw%=3
3410 FOR I%=0 TO (W%*H%)-1
3420 DATR% = ?(graphics+I%*datw%+0) DIV 85
3425 DATG% = ?(graphics+I%*datw%+1) DIV 85
3430 DATB% = ?(graphics+I%*datw%+2) DIV 85
3440 IND% = DATR% * 16 + DATG% * 4 + DATB% : REM RGB colour as index
3450 col% = REVLU%(IND%) : REM Reverse lookup of RGB colour to BBC Colour code
3460 G%(I%, b%) = col% : x%=I% MOD W% : y%=I% DIV W%
3465 PROCfilledRect(1+GRIDX%+x%*8, 1+GRIDY%+y%*8, 6, 6, col%)
3470 NEXT I%
3490 ENDPROC

3500 DEF PROCloadDataFile2bit(f$, b%)
3510 FOR I%=0 TO (W%*H%)-1
3520 DATR% = ?(graphics+I%) AND &03
3525 DATG% = (?(graphics+I%) AND &0C) DIV 4
3530 DATB% = (?(graphics+I%) AND &30) DIV 16
3540 IND% = DATR% * 16 + DATG% * 4 + DATB% : REM RGB colour as index
3550 col% = REVLU%(IND%) : REM Reverse lookup of RGB colour to BBC Colour code
3560 G%(I%, b%) = col% : x%=I% MOD W% : y%=I% DIV W%
3565 PROCfilledRect(1+GRIDX%+x%*8, 1+GRIDY%+y%*8, 6, 6, col%)
3570 NEXT I%
3590 ENDPROC

3650 DEF PROCsaveDataFile(f$, b%, fmt%)
3660 IF fmt%=1 THEN PROCsaveDataFile8bit(f$, b%, 0)
3670 IF fmt%=2 THEN PROCsaveDataFile8bit(f$, b%, 1)
3680 IF fmt%=3 THEN PROCsaveDataFile2bit(f$, b%)
3690 ENDPROC

3700 DEF PROCsaveDataFile8bit(f$, b%, alpha%)
3701 REM save raw data to a file. RGB or RGBA 8bit format with no header.
3705 LOCAL I%, RGBIndex%, h%
3710 h% = OPENOUT(f$)
3720 FOR I%=0 TO (W%*H%)-1
3730 RGBIndex% = CL%(G%(I%, b%)) : REM lookup the RGB colour index for this colour 
3740 BPUT#h%, RGB%(RGBIndex%*3)
3742 BPUT#h%, RGB%(RGBIndex%*3+1)
3744 BPUT#h%, RGB%(RGBIndex%*3+2)
3746 IF alpha%=1 THEN  BPUT#h%, &FF
3750 NEXT
3760 CLOSE#h%
3790 ENDPROC

3800 DEF PROCsaveDataFile2bit(f$, b%)
3801 REM save raw data to a file. RGBA2222 format with no header.
3805 LOCAL I%, RGBIndex%, h%
3810 h% = OPENOUT(f$)
3820 FOR I%=0 TO (W%*H%)-1
3830 RGBIndex% = CL%(G%(I%, b%)) : REM lookup the RGB colour index for this colour 
3832 DATR% =  RGB%(RGBIndex%*3) AND &03
3834 DATG% =  RGB%(RGBIndex%*3+1) AND &03
3836 DATB% =  RGB%(RGBIndex%*3+2) AND &03
3840 out% = &C0 OR DATB%*16 OR DATG%*4 OR DATR%
3845 BPUT#h%, out%
3850 NEXT
3860 CLOSE#h%
3890 ENDPROC

3900 DEF PROCexportData8bit(f$, b%, ln%, alpha%)
3906 PPL%=8 
3910 SS$=STRING$(250," ") 
3915 SS$=STR$(ln%)+" REM "+f$+" "+STR$(W%)+"x"+STR$(H%)+" "
3920 IF alpha%=1 THEN SS$=SS$+" 4 bytes pp RGBA" ELSE SS$=SS$+" 3 bytes pp RGB" 
3922 SS$=SS$+" bitmap num "+STR$(b%+1)
3925 ln%=ln%+10
3930 h% = OPENUP(f$) : IF h%=0 THEN h% = OPENOUT(f$) ELSE PTR#h%=EXT#h% 
3935 FOR I%=0 TO (W%*H%)-1
3940 IF I% MOD PPL% = 0 THEN PROCprintFileLine(h%,SS$) : SS$=STR$(ln%)+" DATA " : ln%=ln%+10
3945 RGBIndex% = CL%(G%(I%, b%)) : REM lookup the RGB colour index for this colour 
3950 FOR J%=0 TO 2
3955 IF RGB%(RGBIndex%*3+J%)=0 THEN SS$ = SS$+"0" ELSE SS$ = SS$+"&"+STR$~(RGB%(RGBIndex%*3+J%))
3960 IF J%<2 THEN SS$=SS$+","
3964 NEXT J%
3966 IF alpha%=1 THEN SS$=SS$+",&FF"
3970 IF I% MOD PPL% < (PPL%-1) THEN SS$=SS$+","
3975 NEXT I%
3980 PROCprintFileLine(h%, SS$)
3985 CLOSE#h%
3990 ENDPROC

4000 DEF PROCexportData2bit(f$,b%,ln%)
4002 LOCAL PIX%,PPL%,SS$,I%,J%,col%
4004 PIX%=0
4006 PPL%=16
4010 SS$=STRING$(250," ") 
4015 SS$=STR$(ln%)+" REM "+f$+" "+STR$(W%)+"x"+STR$(H%)+" 1 byte pp RGBA2222" 
4022 SS$=SS$+" bitmap num "+STR$(b%+1)
4025 ln%=ln%+10
4030 h% = OPENUP(f$) : IF h%=0 THEN h% = OPENOUT(f$) ELSE PTR#h%=EXT#h% 
4035 FOR I%=0 TO (W%*H%)-1
4040 IF I% MOD PPL% = 0 THEN PROCprintFileLine(h%,SS$) : SS$=STR$(ln%)+" DATA " : ln%=ln%+10
4045 RGBIndex% = CL%(G%(I%, b%)) : REM lookup the RGB colour index for this colour 
4047 PIX%=0
4050 FOR J%=0 TO 3
4055 col%=RGB%(RGBIndex%*3+J%) AND 3 : REM convert colour 8bit to 2 bit
4060 PIX%=PIX% OR BSTAB%(col%,J%) : REM bitshift colour and add to final value
4066 NEXT J%
4067 IF RGBIndex%>0 THEN PIX%=PIX% OR &C0 : REM alpha=1
4068 IF PIX%=0 THEN SS$=SS$+"0" ELSE SS$=SS$+"&"+STR$~(PIX%)
4070 IF I% MOD PPL% < (PPL%-1) THEN SS$=SS$+","
4075 NEXT I%
4080 PROCprintFileLine(h%, SS$)
4085 CLOSE#h%
4090 ENDPROC

4100 DEF PROCexport
4105 LOCAL frames% : frames%=1
4110 fmt% = FNinputInt("Format 1)RGB888 2)RGBA8888 3)RGBA2222")
4115 IF fmt%<1 OR fmt%>3 THEN ENDPROC
4120 yn$ = FNinputStr("Multiple Frames (y/N)")
4125 IF yn$ = "y" OR yn$ = "Y" THEN mult%=1 ELSE mult%=0
4130 IF mult%=1 THEN frames% = FNinputInt("Num frames")
4134 IF mult%=1 AND (frames%<1 OR frames%>NumBitmaps%) THEN COLOUR 1:PRINT TAB(32,FLINE%);"Invalid" : ENDPROC
4136 IF mult%=1 THEN bmfrm%=0 : bmto%=frames%-1 ELSE bmfrm%=BM% : bmto%=BM% 
4140 F$ = FNinputStr("Enter filename:")
4145 IF F$ = "" THEN PROCshowFilename(F$) : ENDPROC
4150 Line% = FNinputInt("Line number:")
4160 FOR bmid%=bmfrm% TO bmto% 
4165 COLOUR 10:PRINT TAB(32,FLINE%);"bm=";STR$(bmid%+1);
4170 IF fmt%=1 THEN PROCexportData8bit(F$, bmid%, Line%, 0): Line%=Line%+20*W%+10
4172 IF fmt%=2 THEN PROCexportData8bit(F$, bmid%, Line%, 1): Line%=Line%+20*W%+10
4174 IF fmt%=3 THEN PROCexportData2bit(F$,bmid%,Line%): Line%=Line%+10*W%+10 
4180 NEXT bmid%
4182 COLOUR 10:PRINT TAB(36,FLINE%);"ok";
4185 PROCshowFilename(F$)
4190 ENDPROC

4200 DEF PROCprintFileLine(FH%, S$)
4210 REM dos line endings
4220 PRINT#FH%,S$ : BPUT#FH%,10
4230 ENDPROC

5000 REM ------- Generic Functions ------------

5010 DEF PROCfilledRect(x%,y%,w%,h%,c%)
5005 REM PROCfilledRect draw a filled rectangle
5011 REM assume screen scaling OFF
5012 REM update for basic 3.00, use 85 to plot a triangle, or 101 to plot a filled rect
5020 GCOL 0,c%
5030 MOVE x%,y% 
5040 REM MOVE x%+w%,y% : PLOT 85, x%+w%, y%+h%
5050 REM MOVE x%, y%+h% : PLOT 85, x%, y%
5055 PLOT 101, x%+w%, y%+h%
5060 ENDPROC

5100 DEF PROCrect(x%,y%,w%,h%,c%)
5110 REM PROCrect draw a rectangle. assume screen scaling is OFF
5120 GCOL 0,c%
5130 MOVE x%,y% 
5140 DRAW x%+w%,y% 
5150 DRAW x%+w%, y%+h%
5160 DRAW x%, y%+h% 
5170 DRAW x%, y%
5180 ENDPROC

5200 DEF FNinputStr(prompt$)
5210 PRINT TAB(0,FLINE%);SPC(40);
5220 COLOUR 31 : PRINT TAB(0,FLINE%);prompt$; : COLOUR 15 : INPUT s$
5230 =s$

5250 DEF FNinputInt(prompt$)
5260 PRINT TAB(0,FLINE%);SPC(40);
5270 COLOUR 31 : PRINT TAB(0,FLINE%);prompt$; : COLOUR 15 : INPUT i%
5280 =i%

5300 DEF PROCconfig(conf_file$)
5305 LOCAL in_str$, in_int%, l%
5310 VDU 23,0,192,0,23,1,0 
5315 CLS : PROCprintTitle : l%=4
5320 PROCreadConfigFile(conf_file$)
5325 l%=FNprintConfig(l%) : l%=l%+1
5330 PRINT TAB(0,l%); :C. 15: PRINT "C"; : C. 21: PRINT" to configure, ";
5332 C. 15:PRINT "RETURN";:C. 21:PRINT" to continue.";:C. 15: INPUT in_str$
5335 IF in_str$<>"c" AND in_str$<>"C" THEN ENDPROC
5340 l%=l%+2 : in_int%=FNinputOpts2(l%,"Sprite Size",1,"16x16","8x8") 
5345 IF in_int%=2 THEN CONFIG_SIZE=2 ELSE CONFIG_SIZE=1
5350 l%=l%+1 : in_int%=FNinputOpts2(l%,"Joystick",2,"Yes","No") 
5355 IF in_int%=1 THEN CONFIG_JOY=1 ELSE CONFIG_JOY=0
5360 l%=l%+2 : in_int%=FNinputOpts2(l%, "Type",1,"Bitmaps","Sprite sheet") 
5365 IF in_int%=2 THEN CONFIG_TYPE=2 ELSE CONFIG_TYPE=1
5370 GOTO 5315 : REM this goto makes me sad
5380 IF CONFIG_SIZE=2 THEN W%=8 : H%=8 ELSE W%=16 : H%=16
5395 ENDPROC

5400 DEF FNprintConfig(line%)
5410 C. 21: PRINT TAB(0,line%);"Sprite Size  : "; : C. 19
5420 IF CONFIG_SIZE=2 THEN PRINT "8x8" ELSE PRINT "16x16"
5425 line%=line%+1
5430 C. 21: PRINT TAB(0,line%);"Joystick     : "; : C. 19
5440 IF CONFIG_JOY=1 THEN PRINT "Enabled" ELSE PRINT "Disabled"
5445 line%=line%+1
5450 IF CONFIG_JOY=1 THEN C. 21 : PRINT "Joy Delay    : ";:C. 19 : PRINT ;CONFIG_JOYDELAY;: line%=line%+1
5460 C. 21: PRINT TAB(0,line%);"Editing type : "; : C. 19
5470 IF CONFIG_TYPE=2 THEN PRINT "Sprite Sheet" ELSE PRINT "Bitmaps"
5480 line%=line%+1
5490 =line%

5500 DEF PROCreadConfigFile(f$)
5510 ch%=OPENIN(f$)
5515 C. 7 : PRINT TAB(0,2);f$;": "; : IF ch%=0 THEN C. 9:PRINT "No file"; : ENDPROC
5520 REPEAT
5525 skip=0 : epos=0
5530 INPUT#ch%,s$
5535 IF MID$(s$,1,1)="#" skip=1
5540 IF skip=0 THEN r%=INSTR(s$,CHR$(&0A)) IF r%>0 THEN  s$=MID$(s$,r%+1)
5545 IF skip=0 THEN epos=INSTR(s$,"=")
5550 IF skip=0 AND epos>0 THEN var$=MID$(s$,1,epos-1) : val$=MID$(s$,epos+1)
5555 IF skip=0 AND epos>0 THEN PROCsetConfigVar(var$, val$)
5560 UNTIL EOF#ch%
5585 CLOSE#ch%
5590 ENDPROC

5600 DEF PROCsetConfigVar(var$, val$)
5610 REM PRINT "VAR:";var$;" VAL:";val$
5620 IF var$="JOY" THEN CONFIG_JOY=VAL(val$)
5630 IF var$="SIZE" THEN CONFIG_SIZE=VAL(val$)
5640 IF var$="TYPE" THEN CONFIG_TYPE=VAL(val$)
5650 IF var$="JOYDELAY" THEN CONFIG_JOYDELAY=VAL(val$)
5690 ENDPROC

5700 DEF FNinputOpts2(line%,base$,hili%,opt1$,opt2$)
5710 C. 21: PRINT TAB(0,line%);base$;" ";
5720 IF hili%=1 THEN COLOUR 15
5725 PRINT "1) ";opt1$;" ";
5727 C. 21
5730 IF hili%=2 THEN COLOUR 15
5735 PRINT "2) ";opt2$;" ";
5780 COLOUR 15 : INPUT in%
5790 =in% 

6000 REM ------- Colour lookup Functions ------------
6005 :

6010 DEF PROCloadLUT
6011 REM Load the RGB Look up table
6012 REM CL%() is BBC Col to RGBIndex
6013 REM RGB%() is a packed array of the RGB colours
6014 REM REVLU%() is a reverse lookup table to get the colour  
6020 LOCAL I%
6025 RESTORE 6210
6030 FOR I%=0 TO 63 
6040 READ CL%(I%)
6050 NEXT
6060 FOR I%=0 TO 63
6070 READ RGB%(I%*3),RGB%(I%*3+1),RGB%(I%*3+2),REVLU%(I%)
6080 NEXT
6090 ENDPROC

6200 REM Colour mapping to RGB 
6210 DATA &00, &20, &08, &28, &02, &22, &0A, &2A
6220 DATA &15, &30, &0C, &3C, &03, &33, &0F, &3F
6230 DATA &01, &04, &05, &06, &07, &09, &0B, &0D
6240 DATA &0E, &10, &11, &12, &13, &14, &16, &17
6250 DATA &18, &19, &1A, &1B, &1C, &1D, &1E, &1F
6260 DATA &21, &23, &24, &25, &26, &27, &29, &2B
6270 DATA &2C, &2D, &2E, &2F, &31, &32, &34, &35
6280 DATA &36, &37, &38, &39, &3A, &3B, &3D, &3E
6300 REM - RGB colours with a reverse map
6310 DATA &00, &00, &00,  0, &00, &00, &55, 16, &00, &00, &AA,  4, &00, &00, &FF, 12
6320 DATA &00, &55, &00, 17, &00, &55, &55, 18, &00, &55, &AA, 19, &00, &55, &FF, 20
6330 DATA &00, &AA, &00,  2, &00, &AA, &55, 21, &00, &AA, &AA,  6, &00, &AA, &FF, 22
6340 DATA &00, &FF, &00, 10, &00, &FF, &55, 23, &00, &FF, &AA, 24, &00, &FF, &FF, 14
6350 DATA &55, &00, &00, 25, &55, &00, &55, 26, &55, &00, &AA, 27, &55, &00, &FF, 28
6360 DATA &55, &55, &00, 29, &55, &55, &55,  8, &55, &55, &AA, 30, &55, &55, &FF, 31
6370 DATA &55, &AA, &00, 32, &55, &AA, &55, 33, &55, &AA, &AA, 34, &55, &AA, &FF, 35
6380 DATA &55, &FF, &00, 36, &55, &FF, &55, 37, &55, &FF, &AA, 38, &55, &FF, &FF, 39
6390 DATA &AA, &00, &00,  1, &AA, &00, &55, 40, &AA, &00, &AA,  5, &AA, &00, &FF, 41
6400 DATA &AA, &55, &00, 42, &AA, &55, &55, 43, &AA, &55, &AA, 44, &AA, &55, &FF, 45
6410 DATA &AA, &AA, &00,  3, &AA, &AA, &55, 46, &AA, &AA, &AA,  7, &AA, &AA, &FF, 47
6420 DATA &AA, &FF, &00, 48, &AA, &FF, &55, 49, &AA, &FF, &AA, 50, &AA, &FF, &FF, 51
6430 DATA &FF, &00, &00,  9, &FF, &00, &55, 52, &FF, &00, &AA, 53, &FF, &00, &FF, 13
6440 DATA &FF, &55, &00, 54, &FF, &55, &55, 55, &FF, &55, &AA, 56, &FF, &55, &FF, 57
6450 DATA &FF, &AA, &00, 58, &FF, &AA, &55, 59, &FF, &AA, &AA, 60, &FF, &AA, &FF, 61
6460 DATA &FF, &FF, &00, 11, &FF, &FF, &55, 62, &FF, &FF, &AA, 63, &FF, &FF, &FF, 15

6500 REM lookup table for BitShift for RGBA2222 (don't have nice bit-shift operators)
6510 DEF PROCloadBitshiftTable
6515 LOCAL col%,comp%
6520 RESTORE 6610
6530 FOR comp%=0 TO 3
6540 FOR col%=0 TO 3
6550 READ BSTAB%(col%,comp%) 
6560 NEXT col%
6570 NEXT comp%
6595 ENDPROC

6600 REM bitshift lookup 
6610 DATA 0,1,2,3, 0,4,8,&0C, 0,&10,&20,&30, 0,&40,&80,&C0

10000 REM  ------------ Error Handling -------------
10010 VDU 23, 0, 192, 1 : REM turn on normal logical screen scaling
10020 VDU 23, 1, 1 : REM enable text cursor
10025 @%=&90A
10030 COLOUR 15
10040 IF ISEXIT=0 PRINT:REPORT:PRINT " @ line ";ERL:END
10050 PRINT : PRINT "Goodbye"

