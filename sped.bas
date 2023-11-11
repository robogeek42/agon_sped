10 REM Sprite editor for the Agon Light and Console 8
11 REM NOTE: Requires VDP version 2.0.0+ for the bitmap backed sprite function
15 VERSION$="v0.8"
20 ON ERROR GOTO 10000
25 DIM graphics 1024 : REM memory for file load 
27 MB%=&40000 
30 MODE 8
35 SW%=320 : SH%=240
45 GRIDX%=8 : GRIDY%=16 : W%=16 : H%=16
50 GRIDCOL%=8 : CURSCOL%=15 :ISEXIT=0
55 SCBOXX%=170 : SCBOXY%=148 : REM shortcut box pos
60 DIM CL%(64) : DIM RGB%(64*3) : DIM REVLU%(64) : PROCloadLUT

70 PALX%=8 : PALY%=146 : PALW%=16 : PALH%=4 : REM palette x/y,w/h 
80 PX%=0 : PY%=0 : COL%=1 : REM selected palette colour

100 DIM KEYG(4), KEYP(4) : REM in order left, right, up down 
105 KEY_SET=32 : KEY_DEL=127 : PROCsetkeys
110 FILENAME$="" : FLINE%=24 : REM FLINE is line on which filename appears
120 DIM SKey%(9) : FOR I%=0 TO 9 : SKey%=-1 : NEXT I%

130 REM multi-bitmap sprite setup
135 NumBitmaps% = 6 : BM% = 0 : REM current bitmap
140 NSF% = 3 : SF%=0 : REM Number of sprite frames and current frame
145 Delay%=10 : Ctr%=Delay%

150 REM Calc positions of sprite frame frames
155 SPX%=150 : SPY%=18 : REM sprite x/y position on screen
157 BBOXX%=150 : BBOXY%=42 : REM top-left of bitmap boxes
160 DIM BMX%(NumBitmaps%), BMY%(NumBitmaps%)
165 FOR I%=0 TO NumBitmaps%-1 : BMX%(I%)=BBOXX% + (W%+8)*I% : BMY%(I%)=BBOXY% : NEXT

170 REM declare data for grid
175 DIM G%(W%*H%, NumBitmaps%) 

180 PROCdrawScreen
185 PROCcreateSprite(W%,H%)

190 FOR B%=0 TO NumBitmaps%-1
195 FOR I%=0 TO W%*H%-1 : G%(I%, B%)=0 : NEXT I%
200 NEXT B%

210 FOR B%=0 TO NumBitmaps%-1 : PROCupdateBitmapFromGrid(B%) : NEXT
220 REM PROCupdateScreenGrid(BM%)

240 REM Main Loop
250 REPEAT
260 key=INKEY(0)
270 IF key=-1 GOTO 600 : REM skip to Until
280 PROCgridCursor(0)
290 IF key = 120 ISEXIT=1 : REM x=exit
300 REM grid cursor movement
310 IF key = KEYG(0) AND PX%>0 THEN PX%=PX%-1 : REM left
320 IF key = KEYG(1) AND PX%<15 THEN PX%=PX%+1 : REM right
330 IF key = KEYG(2) AND PY%>0 THEN PY%=PY%-1 : REM up
340 IF key = KEYG(3) AND PY%<15 THEN PY%=PY%+1 : REM down
350 REM colour select movement
360 IF key = KEYP(0) AND COL%>0 THEN PROCselectPaletteCol(COL%-1) : REM left
370 IF key = KEYP(1) AND COL%<63 THEN PROCselectPaletteCol(COL%+1) : REM right
380 IF key = KEYP(2) AND COL%>(PALW%-1) THEN PROCselectPaletteCol(COL%-PALW%) : REM up
390 IF key = KEYP(3) AND COL%<(63-PALW%) THEN PROCselectPaletteCol(COL%+PALW%) : REM down
400 REM space = set colour, backspace = delete (set to 0), f=fill to current col
410 IF key = 32 THEN PROCsetCol(PX%,PY%,COL%)
420 IF key = 127 THEN PROCsetCol(PX%,PY%,0)
430 IF key = 99 THEN PROCclearGrid(0, BM%)
440 IF key = 102 THEN PROCclearGrid(COL%, BM%)
450 IF key = 112 THEN PROCpickCol
460 REM V=save L=load
470 IF key = 118 THEN PROCsaveFile : REM V=saVe file 
480 IF key = 108 THEN PROCloadFile
490 IF key = 109 THEN BM%=(BM%+1) MOD NumBitmaps% : PROCdrawBitmapBoxes : PROCupdateScreenGrid(BM%)
500 IF key = 110 THEN BM%=(BM%-1) : IF BM%<0 THEN BM%=NumBitmaps%-1
510 IF key = 110 THEN PROCdrawBitmapBoxes : PROCupdateScreenGrid(BM%)
520 IF key = 107 THEN PROCsetShortcutKey
530 IF key >=49 AND key <=59 THEN IF SKey%(key-48)>=0 THEN PROCselectPaletteCol(SKey%(key-48))
540 IF key = 114 THEN PROCsetFrames
580 PROCgridCursor(1)

600 REM Nokey GOTO comes here
610 PROCshowSprite
670 UNTIL ISEXIT = 1
680 GOTO 5000

695 STOP

699 REM ------ Static Screen Update Functions ---------------

700 DEF PROCdrawScreen
705 REM draw screen - titles, instructions.
710 LOCAL I%
715 CLS
720 VDU 23,0,192,0 : REM turn off logical screen scaling
730 VDU 23, 1, 0 : REM disable text cursor
740 PROCdrawGrid(W%,H%,GRIDX%,GRIDY%)
745 PROCdrawPalette(PALX%,PALY%)
750 PROCselectPaletteCol(COL%)
760 PROCgridCursor(1)
770 PROCdrawBitmapBoxes
800 COLOUR 54:PRINT TAB(0,0);"SPRITE EDITOR";
810 COLOUR 20:PRINT TAB(14,0);"for the Agon ";
814 COLOUR 8:PRINT TAB(27,0);VERSION$;
816 COLOUR 26:PRINT TAB(32,0);"by Assif";
820 GCOL 0,15 : MOVE 0,10 : DRAW 320,10
830 GCOL 0,15 : MOVE 0,26*8-4 : DRAW 320,26*8-4
840 COLOUR 21 : PRINT TAB(0,26);"Cursor"; :COLOUR 19:PRINT TAB(7,26);"Move";
850 COLOUR 21 : PRINT TAB(0,27);"WASD  "; :COLOUR 19:PRINT TAB(7,27);"Colour";
860 COLOUR 21 : PRINT TAB(0 ,28);"Space"; :COLOUR 19:PRINT TAB(7,28);"Set";
870 COLOUR 21 : PRINT TAB(0, 29);"Backsp";:COLOUR 19:PRINT TAB(7,29);"Unset";
874 COLOUR 21 : PRINT TAB(16,26);"P";     :COLOUR 19:PRINT TAB(21,26);"Pick";
876 COLOUR 21 : PRINT TAB(16,27);"M/N";   :COLOUR 19:PRINT TAB(21,27);"Bitmap";
880 COLOUR 21 : PRINT TAB(16,28);"F";     :COLOUR 19:PRINT TAB(21,28);"Fill";
890 COLOUR 21 : PRINT TAB(16,29);"C";     :COLOUR 19:PRINT TAB(21,29);"Clear";
900 COLOUR 21 : PRINT TAB(30,26);"X";     :COLOUR 19:PRINT TAB(33,26);"eXit";
905 COLOUR 21 : PRINT TAB(30,27);"R";     :COLOUR 19:PRINT TAB(33,27);"fRames";
910 COLOUR 21 : PRINT TAB(30,28);"V";     :COLOUR 19:PRINT TAB(33,28);"saVe";
920 COLOUR 21 : PRINT TAB(30,29);"L";     :COLOUR 19:PRINT TAB(33,29);"Load";
940 COLOUR 7 : FOR I%=1 TO 9 : PRINT TAB((SCBOXX% DIV 8) -1 +I%*2,SCBOXY% DIV 8 +1 );I% : NEXT
945 COLOUR 8 : PRINT TAB((SCBOXX% DIV 8) +1,SCBOXY% DIV 8 +4);"Shortcut K=set";
950 PROCrect(SCBOXX%, SCBOXY%-2,16*9,39,7)
970 PROCshowFilename
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
1320 REM x% = COL% DIV PALH% : y% = COL% MOD PALH% : REM vertical
1325 x% = COL% MOD PALW% : y% = COL% DIV PALW% : REM horizontal
1330 PROCrect(PALX%+x%*10, PALY%+y%*10, 8, 8, 0)
1340 COL%=c%
1350 REM x% = COL% DIV PALH% : y% = COL% MOD PALH% : REM vertical
1355 x% = COL% MOD PALW% : y% = COL% DIV PALW% : REM horizontal
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
2410 COLOUR 31 : PRINT TAB(0,FLINE%);SPC(39);
2415 COLOUR 31 : PRINT TAB(0,FLINE%);"Shortcut (1-9):";
2420 COLOUR 15 : INPUT K
2430 IF K >= 1 AND K <= 9 THEN SKey%(K) = COL% :  PROCfilledRect(SCBOXX%+K*16-10,SCBOXY%+14,6,6,COL%)
2490 ENDPROC

2500 DEF PROCsetFrames
2510 COLOUR 31 : PRINT TAB(0,FLINE%);SPC(39);
2515 COLOUR 31 : PRINT TAB(0,FLINE%);"Num Frames to Show:";
2520 COLOUR 15 : INPUT K
2530 IF K >= 1 AND K <= NumBitmaps% THEN NSF%=K
2540 PROCdrawBitmapBoxes
2550 ENDPROC

3099 REM ------ File Handling --------------------------------

3100 DEF PROCsaveFile
3105 REM ask for a filename and save the data in RGB raw format with no headers
3105 REM ask if they want to save multiple frames
3110 PRINT TAB(0,FLINE%);SPC(39);
3115 COLOUR 31 : PRINT TAB(0,FLINE%);"Multiple Frames (y/N)"; : COLOUR 15 : INPUT yn$
3120 IF yn$ = "y" OR yn$ = "Y" THEN PROCsaveMultiple ELSE PROCsaveSingleFilename
3125 ENDPROC

3130 DEF PROCsaveSingleFilename
3135 REM ask for a filename
3140 PRINT TAB(0,FLINE%);SPC(39);
3145 COLOUR 31 : PRINT TAB(0,FLINE%);"Enter filename:";
3150 COLOUR 15 : INPUT FILENAME$;
3155 PROCshowFilename
3160 FHAN%=OPENOUT(FILENAME$)
3170 REM need an exists/overwrite dialog ...
3180 PROCsaveDataFile(FHAN%, BM%)
3190 ENDPROC

3200 DEF PROCsaveMultiple
3205 LOCAL Prefix$, NumFrames%, N%, F$
3210 PRINT TAB(0,FLINE%);SPC(39);
3220 COLOUR 31 : PRINT TAB(0,FLINE%);"Enter prefix:";
3225 COLOUR 15 : INPUT Prefix$;
3230 COLOUR 31 : PRINT TAB(0,FLINE%);"Enter num frames:";
3235 COLOUR 15 : INPUT NumFrames$; : NumFrames%=VAL(NumFrames$)
3240 IF NumFrames% <1 OR NumFrames% > NumBitmaps% THEN COLOUR 1 : PRINT TAB(30,FLINE%);"Not valid" : ENDPROC
3245 @%=&01000202
3250 FOR N%=0 TO NumFrames%-1
3260 F$ = Prefix$ + STR$(N%) + ".rgb"
3265 FHAN%=OPENOUT(F$)
3270 COLOUR 7 : PRINT TAB(22,FLINE%);F$;
3275 PROCsaveDataFile(FHAN%, N%)
3280 NEXT N%
3290 ENDPROC 

3300 DEF PROCloadFile
3305 REM ask for a filename, and call load routine 
3310 PRINT TAB(0,FLINE%);SPC(39);
3320 COLOUR 31 : PRINT TAB(0,FLINE%);"Enter filename:";
3330 COLOUR 15 : INPUT FILENAME$;
3340 FHAN%=OPENIN(FILENAME$)
3350 IF FHAN% = 0 THEN COLOUR 1:PRINT TAB(30,FLINE%);"No file"; :FILENAME$="": ENDPROC
3360 FLEN%=EXT#FHAN% : IF FLEN%<>768 THEN COLOUR 1:PRINT TAB(30,FLINE%);"Not valid";:FILENAME$="": CLOSE#FHAN%: ENDPROC
3370 CLOSE#FHAN% : PROCloadDataFile(FHAN%)
3390 ENDPROC

3400 DEF PROCshowFilename
3405 REM just display filename in status bar
3410 GCOL 0,15 : MOVE 0,FLINE%*8-4 : DRAW 320,FLINE%*8-4
3420 PRINT TAB(0,FLINE%);SPC(39);
3430 COLOUR 31 : PRINT TAB(0,FLINE%);"FILE:";TAB(6,FLINE%);FILENAME$;
3490 ENDPROC

3500 DEF PROCloadDataFile(h%)
3501 REM this loads file to internal memory and copies it out to the sprite
3502 LOCAL col%, I%, IND%
3505 OSCLI("LOAD " + FILENAME$ + " " + STR$(MB%+graphics))
3510 FOR I%=0 TO (W%*H%)-1
3520 DATR% = ?(graphics+I%*3+0) DIV 85
3530 DATG% = ?(graphics+I%*3+1) DIV 85
3540 DATB% = ?(graphics+I%*3+2) DIV 85
3550 IND% = DATR% * 16 + DATG% * 4 + DATB% : REM RGB colour as index
3560 col% = REVLU%(IND%) : REM Reverse lookup of RGB colour to BBC Colour code
3570 G%(I%, BM%) = col% : x%=I% MOD W% : y%=I% DIV W%
3580 PROCfilledRect(1+GRIDX%+x%*8, 1+GRIDY%+y%*8, 6, 6, col%)
3590 NEXT I%
3600 PROCdrawGrid(W%,H%,GRIDX%,GRIDY%)
3610 PROCupdateBitmapFromGrid(BM%)
3690 ENDPROC

3700 DEF PROCsaveDataFile(h%, b%)
3701 REM save raw data to a file. RGB format with no header.
3705 LOCAL I%, RGBIndex%
3710 FOR I%=0 TO (W%*H%)-1
3720 RGBIndex% = CL%(G%(I%, b%)) : REM lookup the RGB colour index for this colour 
3730 BPUT#h%, RGB%(RGBIndex%*3)
3740 BPUT#h%, RGB%(RGBIndex%*3+1)
3750 BPUT#h%, RGB%(RGBIndex%*3+2)
3760 NEXT
3770 CLOSE#h%
3790 ENDPROC

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

6000 REM ------- Colour lookup Functions ------------
6005 :

6010 DEF PROCloadLUT
6011 REM Load the RGB Look up table
6012 REM CL%() is BBC Col to RGBIndex
6013 REM RGB%() is a packed array of the RGB colours
6014 REM REVLU%() is a reverse lookup table to get the colour  
6020 LOCAL I%
6025 RESTORE
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

10000 REM  ------------ Error Handling -------------
10010 VDU 23, 0, 192, 1 : REM turn on normal logical screen scaling
10020 VDU 23, 1, 1 : REM enable text cursor
10025 @%=0
10030 COLOUR 15
10040 IF ISEXIT=0 PRINT:REPORT:PRINT " @ line ";ERL:END
10050 PRINT "Goodbye"

