10 REM Sprite editor for the Agon Light and Console8 by Assif (robogeek42)
20 VERSION$="v1.02"
30 ON ERROR GOTO 15010
40 DIM graphics 1024 : REM memory for file load 
50 IF HIMEM>65536 THEN ADL=1 ELSE ADL=0 : REM 24-bit addr basic
60 IF ADL=1 THEN MB%=0 ELSE MB%=&40000
70 MODE 8
80 ISEXIT=0 : SW%=320 : SH%=240 

100 REM ----- config in sped.ini -----
110 CONFIG_SIZE=1 : CONFIG_JOY=0
120 CONFIG_JOYDELAY=20 : BM_MAX=8
130 C1=21: C2=19: REM Help colours (C1=highlight)
140 PROCconfig("sped.ini")
150 IF CONFIG_SIZE=1 THEN BMW%=16 : BMH%=16
155 IF CONFIG_SIZE=2 THEN BMW%=8 : BMH%=8
160 WH%=BMW%*BMH%
170 IF CONFIG_SIZE=1 AND BM_MAX>24 THEN BM_MAX=24
175 IF CONFIG_SIZE=2 AND BM_MAX>48 THEN BM_MAX=48

200 REM --------------------------------
210 GRIDX%=1 : GRIDY%=16 : REM Grid position
220 GRIDCOL%=8 : CURSCOL%=15
230 SCBOXX%=170 : SCBOXY%=148 : REM shortcut box pos
240 DIM CL%(64) : DIM REVLU%(64) : PROCloadLUT
250 DIM BSTAB%(3,3), TTE%(4) : PROCloadBitshiftTable
260 PALX%=1 : PALY%=146 : PALW%=16 : PALH%=4 : REM palette x/y,w/h 
270 COL%=1 : REM selected palette colour
275 TRANSP%=-1
280 PX%=0 : PY%=0 : REM position
290 BSstate%=0 : DIM BSrect%(4) : REM block select
300 HaveBlock%=0 : DIM BLOCK%(WH%) : BlockW%=0:BlockH%=0 : REM copied block
330 DIM KEYG(4), KEYP(4) : REM in order left, right, up down 
340 KEY_SET=32 : KEY_DEL=127 : PROCsetkeys
350 FLINE%=24 : REM FLINE is line on which filename appears
360 F$=STRING$(20," ") 
370 DIM SKey%(9) : FOR I%=0 TO 9 : SKey%=-1 : NEXT I%
380 REM multi-bitmap sprite setup
390 NB% = BM_MAX : BM% = 0 : REM number of and current bitmap
410 SF%=0 : REM current frame (bitmap) being edited 
420 LFS%=0 : LFE%=0 : REM Loop frame start and end
430 SpriteDelay%=10 : Ctr%=SpriteDelay%
440 LoopType%=0 : REM 0=left to right loop, 1=ping-pong
450 LoopDir%=1
460 SPX%=134 : SPY%=18 : REM sprite x/y position on screen
470 IF CONFIG_SIZE=1 NBperrow%=8 :BBOXX%=133 : BBOXY%=44 : REM top-left of bitmap boxes
475 IF CONFIG_SIZE=2 NBperrow%=12:BBOXX%=84 : BBOXY%=44 : REM top-left of bitmap boxes
480 DIM BMX%(NB%), BMY%(NB%)
484 IF CONFIG_SIZE=1 THEN NBxsp%=24 : NBysp%=32
486 IF CONFIG_SIZE=2 THEN NBxsp%=20 : NBysp%=24
490 FOR I%=0 TO NB%-1 : BMX%(I%)=BBOXX% + NBxsp%*(I% MOD NBperrow%) : BMY%(I%)=BBOXY%+NBysp%*(I% DIV NBperrow%) : NEXT
500 REM declare data for grid
510 DIM G% WH%*NB%
520 DIM U% WH% : REM for a simple, one level Undo
530 DIM R% WH% : REM rotation work area
535 undo%=0 : REM if undo was saved as a block
540 FFlenMAX%=WH% : DIM FF%(WH%) : FFlen%=0 : REM stack for flood fill
550 PROCdrawScreen
560 COLOR 15 : PRINT TAB(12,FLINE%);"LOADING";
570 PROCcreateSprite(BMW%,BMH%)
580 REM clear arrays
590 FOR b%=0 TO NB%-1 : PROCwbarr(G%+b%*WH%,WH%,0): NEXT b%
600 PROCwbarr(U%,WH%,0)
610 COLOR 15 : PRINT TAB(12,FLINE%);"       ";

700 REM ------ Main Loop ------
710 REPEAT
720 key=INKEY(0)
730 IF CONFIG_JOY=1 JOY=GET(158) : BUTTON=GET(162) ELSE JOY=0 : BUTTON=0
740 IF CONFIG_JOY=0 AND key=-1 GOTO 1360
750 IF key=-1 AND JOY=255 AND BUTTON=247 GOTO 1360 : REM skip to Until
760 PROCgridCursor(0) : PROCblockCursor(0)
770 IF key = ASC("x") OR key=ASC("X") ISEXIT=1 : REM x=exit
780 IF ISEXIT=1 THEN yn$=FNinputStr("Are you sure (y/N)"): IF yn$<>"Y" AND yn$<>"y" THEN ISEXIT=0
790 REM grid cursor movement
800 IF key = KEYG(0) AND PX%>0 THEN PX%=PX%-1 : REM left
810 IF key = KEYG(1) AND PX%<(BMW%-1) THEN PX%=PX%+1 : REM right
820 IF key = KEYG(2) AND PY%>0 THEN PY%=PY%-1 : REM up
830 IF key = KEYG(3) AND PY%<(BMH%-1) THEN PY%=PY%+1 : REM down
840 REM joystick movement 
850 IF JOY>0 AND (JOY AND 223)=JOY AND PX%>0 THEN PX%=PX%-1 : TIME=0: REPEATUNTILTIME>CONFIG_JOYDELAY : REM LEFT
860 IF JOY>0 AND (JOY AND 127)=JOY AND PX%<(BMW%-1) THEN PX%=PX%+1 : TIME=0: REPEATUNTILTIME>CONFIG_JOYDELAY : REM RIGHT
870 IF JOY>0 AND (JOY AND 253)=JOY AND PY%>0 THEN PY%=PY%-1 : TIME=0 : REPEATUNTILTIME>CONFIG_JOYDELAY : REM UP
880 IF JOY>0 AND (JOY AND 247)=JOY AND PY%<(BMH%-1) THEN PY%=PY%+1 : TIME=0 : REPEATUNTILTIME>CONFIG_JOYDELAY :REM DOWN
890 REM colour select movement
900 IF (key = KEYP(0) OR key=KEYP(0)-32) AND COL%>0 THEN PROCselectPaletteCol(COL%-1) : REM left
910 IF (key = KEYP(1) OR key=KEYP(1)-32) AND COL%<63 THEN PROCselectPaletteCol(COL%+1) : REM right
920 IF (key = KEYP(2) OR key=KEYP(2)-32) AND COL%>(PALW%-1) THEN PROCselectPaletteCol(COL%-PALW%) : REM up
930 IF (key = KEYP(3) OR key=KEYP(3)-32) AND COL%<=(63-PALW%) THEN PROCselectPaletteCol(COL%+PALW%) : REM down
940 REM space = set colour, backspace = delete (set to 0), f=fill to current col
950 IF key = 32 OR key = 13 THEN PROCsetCol(PX%,PY%,COL%)
960 IF BUTTON=215 THEN PROCsetCol(PX%,PY%,COL%)
970 IF key = 127  THEN PROCsetCol(PX%,PY%,0)
980 IF (key = ASC("c") OR key=ASC("C")) AND BSstate%=0 THEN PROCclearGrid(0, BM%)
990 IF (key = ASC("c") OR key=ASC("C")) AND BSstate%>0 THEN PROCblockFill(0, BM%)
1000 IF (key = ASC("f") OR key=ASC("F")) AND BSstate%=0 THEN PROCclearGrid(COL%, BM%)
1010 IF (key = ASC("f") OR key=ASC("F")) AND BSstate%>0 THEN PROCblockFill(COL%, BM%)
1020 IF key = ASC("p") OR key=ASC("P") THEN PROCpickCol
1030 IF key = ASC("b") OR key=ASC("B") THEN PROCmarkBlock 
1040 REM V=save L=load
1050 IF key = ASC("l") OR key=ASC("L") THEN PROCloadSaveFile(0)
1060 IF key = ASC("v") OR key=ASC("V") THEN PROCloadSaveFile(1) : REM V=saVe file 
1070 IF key = ASC("e") OR key=ASC("E") THEN PROCexport
1080 REM M,N select bitmap
1090 IF key = ASC(".") OR key=ASC(">") THEN BM%=(BM%+1) MOD NB% : PROCdrawBitmapBoxes(BM%) : PROCupdateScreenGrid(BM%)
1100 IF key = ASC(",") OR key=ASC("<") THEN BM%=(BM%-1) : IF BM%<0 THEN BM%=NB%-1
1110 IF key = ASC(",") OR key=ASC("<") THEN PROCdrawBitmapBoxes(BM%) : PROCupdateScreenGrid(BM%)
1120 IF key = ASC("g") OR key=ASC("G") THEN PROCgotoBitmap
1130 IF key = ASC("k") OR key=ASC("K") THEN PROCsetShortcutKey
1140 REM Palette shortcut key, frames select and Loop/cycle type
1150 IF key >= ASC("1") AND key <= ASC("9") THEN IF SKey%(key-48)>=0 THEN PROCselectPaletteCol(SKey%(key-48))
1160 IF key = ASC("m") OR key=ASC("M") THEN PROCsetFrames
1170 IF key = ASC("y") OR key=ASC("Y") THEN PROCtoggleLoopType
1180 IF key = ASC("r") OR key=ASC("R") THEN PROCsetLoopSpeed
1190 IF key = ASC("-") AND BSstate%=0 THEN PROCcopyImage(BM%)
1200 IF key = ASC("-") AND BSstate%>0 THEN PROCcopyBlock(BM%)
1210 IF key = ASC("=") AND HaveBlock%=1 THEN PROCpasteBlock(BM%)
1220 IF key = ASC("#") AND BSstate%=0 THEN PROCmirrorSelected(0,0,BMW%-1,BMH%-1,BM%)
1230 IF key = ASC("#") AND BSstate%>0 THEN PROCmirrorSelected(BSrect%(0),BSrect%(1),BSrect%(2),BSrect%(3),BM%)
1240 IF key = ASC("~") AND BSstate%=0 THEN PROCflipSelected(0,0,BMW%-1,BMH%-1,BM%)
1250 IF key = ASC("~") AND BSstate%>0 THEN PROCflipSelected(BSrect%(0),BSrect%(1),BSrect%(2),BSrect%(3),BM%)
1260 IF key = ASC("u") OR key = ASC("U") THEN PROCdoUndo(BM%)
1270 IF key = ASC("/") THEN PROCfloodFill(PX%,PY%,COL%,BM%)
1280 IF key = ASC("]") AND BSstate%=0 THEN PROCrotateSelected(0,0,0,BMW%-1,BMH%-1,BM%)
1290 IF key = ASC("]") AND BSstate%>0 THEN PROCrotateSelected(0,BSrect%(0),BSrect%(1),BSrect%(2),BSrect%(3),BM%)
1300 IF key = ASC("[") AND BSstate%=0 THEN PROCrotateSelected(1,0,0,BMW%-1,BMH%-1,BM%)
1310 IF key = ASC("[") AND BSstate%>0 THEN PROCrotateSelected(1,BSrect%(0),BSrect%(1),BSrect%(2),BSrect%(3),BM%)
1315 IF key = ASC("t") OR key=ASC("T") THEN PROCselectTransp(COL%)
1320 REM PROCshowFilename("")
1330 PROCprintSecondHelp(26)
1340 PROCgridCursor(1) : PROCblockCursor(1)
1350 REM Nokey GOTO comes here
1360 REM LABEL_skipkeys:
1370 PROCshowSprite
1380 UNTIL ISEXIT = 1
1390 GOTO 15010
1400 END

1500 REM ------ Static Screen Update Functions

1600 DEF PROCprintTitle
1610 COLOUR 54:PRINT TAB(0,0);"SPRITE EDITOR";
1620 COLOUR 20:PRINT TAB(14,0);"for the Agon ";
1630 COLOUR 8:PRINT TAB(35,0);VERSION$;
1640 GCOL 0,15 : MOVE 0,10 : DRAW 320,10
1650 ENDPROC

1700 DEF PROCdrawScreen
1710 REM draw screen - titles, instructions.
1720 LOCAL I%
1730 CLS : VDU 23,0,192,0 : REM turn off logical screen scaling
1740 VDU 23, 1, 0 : REM disable text cursor
1750 PROCdrawGrid(BMW%,BMH%,GRIDX%,GRIDY%)
1760 PROCdrawPalette(PALX%,PALY%)
1770 PROCselectPaletteCol(COL%)
1780 PROCgridCursor(1)
1790 PROCdrawBitmapBoxes(BM%)
1800 PROCsetupChars
1810 PROCprintTitle
1820 PROCprintHelp
1830 PROCclearStatusLine
1840 COLOUR 15
1850 ENDPROC

1900 DEF PROCprintHelp
1910 GCOL 0,15 : MOVE 0,26*8-4 : DRAW 320,26*8-4
1920 PROCprintMainHelp(26)
1930 PROCprintSecondHelp(26)
1940 PROCprintBitmapHelp(19,4)
1950 PROCshortcutBox
1960 ENDPROC

2000 DEF PROCshort(x,y,pre$,hi$,post$)
2010 PRINT TAB(x,y);
2020 C. C2: PRINT pre$;
2030 C. C1: PRINT hi$;
2040 C. C2: PRINT post$;
2050 ENDPROC

2100 DEF PROCprintMainHelp(v%)
2110 C. C1 : PRINT TAB(0,v%+0);:VDU 240,243,244,242: C. C2: PRINT TAB(5,v%+0);"Move";
2120 C. C1 : PRINT TAB(0,v%+1);"WASD";:   C. C2: PRINT TAB(5,v%+1);"Color";
2130 C. C1 : PRINT TAB(0,v%+2);"Spc";:    C. C2: PRINT TAB(5,v%+2);"Set";
2140 C. C1 : PRINT TAB(0,v%+3);"Bksp";:   C. C2: PRINT TAB(5,v%+3);"Del";
2150 GCOL 0,15 : MOVE 10*8+4,26*8 : DRAW 10*8+4,31*8+2
2160 ENDPROC

2200 DEF PROCprintSecondHelp(v%)
2210 PROCshort(11,v%,"","L","oad"): PROCshort(17,v%,"sa","V","e"): PROCshort(23,v%,"","E","xport"): PROCshort(30,v%,"","U","ndo"):  PROCshort(36,v%,"e","X","it")
2220 PROCshort(11,v%+1,"","P","ick"): PROCshort(17,v%+1,"","C","lear"): PROCshort(23,v%+1,"","F","ill") : PROCshort(30,v%+1,"","/","flood")
2230 PROCshort(11,v%+2,"","B","lock") 
2240 PROCshort(17,v%+2,"","-","copy")
2250 IF HaveBlock% THEN PROCshort(23,v%+2,"","=","paste") ELSE C.8:PRINT TAB(23,v%+2);"=paste";
2260 PROCshort(23,v%+3,"","~","flip") : PROCshort(30,v%+3,"","#","mirror")
2270 PROCshort(11,v%+3,"","[]","rotate") 
2280 ENDPROC

2300 DEF PROCshortcutBox
2310 COLOUR 7 : FOR I%=1 TO 9 : PRINT TAB((SCBOXX% DIV 8) -1 +I%*2,SCBOXY% DIV 8 +1 );I% : NEXT
2320 PROCshort((SCBOXX% DIV 8) +1,SCBOXY% DIV 8 +4,"Short-","K","ey ")
2325 PROCshort((SCBOXX% DIV 8) +11,SCBOXY% DIV 8 +4,"","T","ransp")
2330 PROCrect(SCBOXX%, SCBOXY%-2,16*9,39,7)
2340 ENDPROC

2400 DEF PROCprintBitmapHelp(x%,y%)
2410 PROCshort(x%   ,y% ,"","<>G","o")
2420 PROCshort(x%+ 5,y% ,"fra","M","es")
2430 PROCshort(x%+12,y% ,"t","Y","pe") 
2440 PROCshort(x%+17,y% ,"","R","ate")
2450 COLOUR 54 : PRINT TAB((SPX%+BMW%)DIV8+2,2);
2460 IF LoopType%=0 THEN PRINT CHR$(242);
2470 IF LoopType%=1 THEN PRINT CHR$(241);
2480 ENDPROC

2500 DEF PROCdrawGrid(w%,h%,x%,y%)
2510 REM drawgrid in GRIDCOL%
2520 GCOL 0,GRIDCOL%
2530 FOR Y%=0 TO h%
2540 PLOT 4, x%, y%+Y%*8
2550 PLOT 5, x%+w%*8, y%+Y%*8
2560 NEXT Y%
2570 FOR X%=0 TO w%
2580 PLOT 4, x%+X%*8, y%
2590 PLOT 5, x%+X%*8, y%+h%*8
2600 NEXT
2610 ENDPROC

2700 DEF PROCdrawBitmapBoxes(b%)
2710 FOR S%=0 TO NB%-1
2720 IF S% = b% THEN gc%=CURSCOL% ELSE gc%=GRIDCOL%
2730 PROCrect(BMX%(S%)-2, BMY%(S%)-2, BMW%+3, BMH%+3, gc%)
2740 IF S%>=LFS% AND S%<=LFE% THEN COLOUR 1 ELSE COLOUR 8
2750 IF CONFIG_SIZE=1 THEN PRINT TAB(BMX%(S%)DIV8+1, (BMY%(S%)+BMH%)DIV8+1);S%+1;
2755 IF CONFIG_SIZE=2 AND S% MOD 2=0 THEN PRINT TAB(BMX%(S%)DIV8, (BMY%(S%)+BMH%)DIV8+1);S%+1;
2756 IF CONFIG_SIZE=2 AND S% MOD 2=1 THEN PRINT TAB(BMX%(S%)DIV8, (BMY%(S%)+BMH%)DIV8+1);"  ";
2757 IF CONFIG_SIZE=2 AND (S%=LFS% OR S%=LFE%) THEN PRINT TAB(BMX%(S%)DIV8, (BMY%(S%)+BMH%)DIV8+1);S%+1;
2760 NEXT
2770 ENDPROC

2800 DEF PROCgotoBitmap
2810 K = FNinputInt("Goto bitmap:")
2820 IF K >= 1 AND K <= NB% THEN BM%=K-1
2830 PROCupdateScreenGrid(BM%)
2840 PROCdrawBitmapBoxes(BM%)
2850 ENDPROC

2900 DEF PROCsetkeys
2910 REM set the keys used for movment.
2920 KEYG(0)=8 : KEYG(1)=21 : KEYG(2)=11 : KEYG(3)=10 
2930 KEYP(0)=97 : KEYP(1)=100 : KEYP(2)=119 : KEYP(3)=115 
2940 ENDPROC

3000 DEF PROCdrawPalette(x%,y%)
3010 REM draw palette colours - I% across, J% down
3020 LOCAL I%,J%, C%
3030 C%=0
3040 FOR J%=0 TO PALH%-1
3050 FOR I%=0 TO PALW%-1
3060 PROCcsquare(1+x%+I%*10,1+y%+J%*10,C%)
3070 C%=C%+1
3080 NEXT I%
3090 NEXT J%
3100 ENDPROC

3200 DEF PROCselectPaletteCol(c%)
3210 REM select colour in palette
3220 x% = COL% MOD PALW% : y% = COL% DIV PALW% : REM horizontal
3230 PROCrect(PALX%+x%*10, PALY%+y%*10, 8, 8, 0)
3240 REM select new colour
3250 COL%=c%
3260 x% = COL% MOD PALW% : y% = COL% DIV PALW% : REM horizontal
3270 PROCrect(PALX%+x%*10, PALY%+y%*10, 8, 8, 15)
3280 PROCprintColour(27,2)
3290 ENDPROC

3400 DEF PROCpickCol
3410 LOCAL col%
3420 col% = G%?(PX% + PY%*BMW% + BM%*WH%)
3430 PROCselectPaletteCol(col%)
3440 ENDPROC

3500 DEF PROCgridCursor(switch%)
3510 REM draw gridcursor
3520 LOCAL col%
3530 IF BSstate%>0 THEN ENDPROC
3540 col%=GRIDCOL% : REM off
3550 IF switch%=1 THEN col%=CURSCOL% : REM on
3560 PROCrect(GRIDX%+PX%*8, GRIDY%+PY%*8, 8, 8, col%)
3570 ENDPROC

3600 DEF PROCprintColour(x%,y%)
3610 REM print colour
3620 LOCAL clu%
3630 clu%=CL%(COL%)
3640 PRINT TAB(x%,y%);SPC(6); 
3650 COLOUR 15: PRINT TAB(x%,y%);"COL ";COL%;
3660 REM hex
3670 COLOUR 9 : PRINT TAB(x%+7,y%);"00";
3680 COLOUR 9 : PRINT TAB(x%+7,y%);~FNindTOrgb(clu%,0);
3690 COLOUR 10: PRINT TAB(x%+9,y%);"00";
3700 COLOUR 10: PRINT TAB(x%+9,y%);~FNindTOrgb(clu%,1);
3710 COLOUR 12: PRINT TAB(x%+11,y%);"00";
3720 COLOUR 12: PRINT TAB(x%+11,y%);~FNindTOrgb(clu%,2);
3730 COLOUR 15
3740 ENDPROC

3800 DEF PROCselectTransp(c%)
3810 x% = c% MOD PALW% : y% = c% DIV PALW% : REM horizontal
3815 IF TRANSP%=-1 THEN PROCcross(1+PALX%+x%*10, 1+PALY%+y%*10, 6, 6, c%) : TRANSP%=c% : ENDPROC
3820 IF TRANSP%=c% THEN PROCcsquare(1+PALX%+x%*10, 1+PALY%+y%*10, TRANSP%) : TRANSP%=-1 : ENDPROC
3823 x% = TRANSP% MOD PALW% : y% = TRANSP% DIV PALW%
3825 PROCcsquare(1+PALX%+x%*10, 1+PALY%+y%*10, TRANSP%)
3830 TRANSP%=c% : x% = TRANSP% MOD PALW% : y% = TRANSP% DIV PALW%
3835 PROCcross(1+PALX%+x%*10, 1+PALY%+y%*10, 6, 6, TRANSP%)
3840 ENDPROC

3850 DEF PROCcross(x%,y%,w%,h%,c%)
3855 l%=CL%(c%): opp%=REVLU%(63-l%):  REM IF l% < 31 THEN opp%=15 ELSE opp%=0 
3857 GCOL 0,opp%
3860 MOVE x%,y% : DRAW x%+w%,y%+h%
3870 MOVE x%+w%,y% : DRAW x%,y%+h%
3880 ENDPROC

3899 REM ------ Grid/Bitmap Update Functions

3900 DEF PROCsetCol(x%,y%,c%)
3910 REM set colour in screen grid AND Data Grid G%
3915 IF undo%=1 THEN PROCsaveUndo(BM%)
3920 ind%=x%+y%*BMW%: U%?ind% = G%?(ind% + BM%*WH%) 
3930 G%?(ind% + BM%*WH%)=c%
3940 PROCcsquare(1+GRIDX%+x%*8, 1+GRIDY%+y%*8, c%)
3950 PROCupdateBitmapPixel(BM%, x%, y%, c%)
3955 undo%=0
3960 ENDPROC

4000 DEF PROCclearGrid(col%, bmap%)
4010 REM clear grid to a colour
4020 LOCAL i%
4030 PROCsaveUndo(bmap%)
4040 PROCwbarr(G%+bmap%*WH%, WH%, col%)
4050 REM fast clear all cells
4060 PROCfilledRect(GRIDX%,GRIDY%, BMW%*8,BMH%*8,col%)
4070 PROCdrawGrid(BMW%,BMH%,GRIDX%,GRIDY%)
4080 PROCupdateBitmapFromGrid(bmap%)
4090 ENDPROC

4200 DEF PROCupdateScreenGrid(bmap%)
4210 REM Update the screen grid from data grid for given bitmap
4220 LOCAL col%,M%,I%,x%,y%
4230 M%=G%+bmap%*WH%
4240 FOR I%=0 TO WH%-1
4250 col%=M%?I%
4260 x%=I% MOD BMW% : y%=I% DIV BMW%
4270 PROCcsquare(1+GRIDX%+x%*8, 1+GRIDY%+y%*8, col%)
4280 NEXT I%
4290 ENDPROC

4400 DEF PROCupdateBitmapFromGrid(bmap%)
4410 REM update bitmap from its data drid
4420 LOCAL clu%,M%,I%
4430 VDU 23,27,0,bmap%   : REM Select bitmap n
4440 VDU 23,0,&A0,bmap%+&FA00;5,&C2,0;WH%;
4450 M%=G%+bmap%*WH%
4460 FOR I%=0 TO WH%-1
4470 clu%=CL%(M%?I%)     : REM lookup RGB index
4480 VDU FNindTOrgb2(clu%)
4490 NEXT
4500 PROCupdateSpriteBitmap(bmap%)
4510 ENDPROC

4600 DEF PROCupdateBitmapPixel(bmap%, x%, y%, c%)
4610 REM update a single bitmap pixel
4620 LOCAL clu%
4630 VDU 23,27,0,bmap%   : REM Select bitmap n
4640 REM Use Adjust Buffer API
4650 VDU 23,0,&A0,bmap%+&FA00;5,&C2,(x%+y%*BMW%);1;
4660 clu%=CL%(c%)     : REM lookup RGB index
4670 VDU FNindTOrgb2(clu%)
4680 PROCupdateSpriteBitmap(bmap%)
4690 ENDPROC

4800 REM ------ Sprite Functions

4900 DEF PROCcreateSprite(w%,h%)
4910 REM setup the sprite and bitmap. Clear both grids
4920 LOCAL b%
4930 FOR b%=0 TO NB%-1
4940 VDU 23,0,&A0,b%+&FA00;2        : REM clear bitmap buffer
4950 VDU 23,0,&A0,b%+&FA00;3,w%*h%; : REM create buffer for RGB2 data
4960 VDU 23,27,0,b%                 : REM Select bitmap
4970 VDU 23,27,&21,w%;h%;1          : REM create bitmap from buffer. RGBA2222
4980 VDU 23,0,&A0,b%;5,&42,0;w%*h%;0: REM clear buffer to 0
4990 NEXT b%
5000 VDU 23,27,4,0        : REM Select sprite 0
5010 VDU 23,27,5          : REM Clear frames
5020 FOR b%=0 TO NB%-1
5030 VDU 23,27,6,b%       : REM Add bitmap n as a frame of sprite
5040 NEXT b%
5050 VDU 23,27,11         : REM Show
5060 VDU 23,27,7,1        : REM activate
5070 VDU 23,27,13,SPX%; SPY%; : REM display
5080 ENDPROC

5100 DEF PROCupdateSpriteBitmap(bmap%)
5110 REM display bitmap and update sprite with bitmap
5120 VDU 23,27,0,bmap%
5130 VDU 23,27,3,BMX%(bmap%);BMY%(bmap%); : REM draw bitmap
5140 VDU 23,27,15: REM Refresh the sprites
5150 ENDPROC

5200 DEF PROCtoggleLoopType
5210 REM loop type : 0=left to right loop, 1=ping-pong
5220 LoopType%=1-LoopType% : LoopDir%=1 : SF%=LFS%
5230 PROCprintBitmapHelp(19,4)
5240 ENDPROC

5300 DEF PROCsetLoopSpeed
5310 LS=FNinputInt("Loop Speed (1-99)")
5320 IF LS>0 AND LS<100 THEN SpriteDelay%=LS
5330 ENDPROC

5400 DEF PROCshowSprite
5410 REM show sprite animation
5420 Ctr% = Ctr% - 1
5430 IF Ctr%=0 PROCupdateAnim : Ctr%=SpriteDelay%
5440 VDU 23,27,10,SF% : REM select frame
5450 *FX 19 : REM wait for refresh
5460 VDU 23,27,15 : REM update sprites
5470 ENDPROC 

5500 DEF PROCupdateAnim
5510 IF LoopType%=0 PROCanimUp
5520 IF LoopType%=1 PROCanimPingPong
5530 ENDPROC

5600 DEF PROCanimUp
5610 SF%=SF%+1
5620 IF SF% > LFE% THEN SF%=LFS%
5630 ENDPROC

5700 DEF PROCanimPingPong
5710 SF%=SF%+LoopDir%
5720 IF LoopDir%= 1 AND SF%>=LFE% THEN LoopDir%=-1 
5730 IF LoopDir%=-1 AND SF%<=LFS% THEN LoopDir%= 1 
5740 ENDPROC

5800 REM ------ Set shortcut keys, Frames etc. ----------------

5900 DEF PROCsetFrames
5910 startf = FNinputInt("Start frame:")
5920 IF startf <1 OR startf>NB% THEN COLOUR 1 : PRINT TAB(32,FLINE%);"Invalid" : ENDPROC
5930 endf = FNinputInt("End frame:")
5940 IF endf < startf OR endf > NB% THEN COLOUR 1 : PRINT TAB(32,FLINE%);"Invalid" : ENDPROC
5950 LFS%=startf-1 : LFE%=endf-1 : SF%=startf-1 : LoopDir%=1
5960 PROCdrawBitmapBoxes(BM%)
5970 ENDPROC

6000 DEF PROCsetShortcutKey
6010 K = FNinputInt("Shortcut (1-9):")
6020 IF K >= 1 AND K <= 9 THEN SKey%(K) = COL% :  PROCcsquare(SCBOXX%+K*16-10,SCBOXY%+14,COL%)
6030 ENDPROC

6100 REM ------ undo

6200 DEF PROCdoUndo(b%)
6210 LOCAL I%,t%, M%
6220 M%=G%+WH%*b%
6230 REM swap undo/grid so using undo again, restores state
6240 FOR I%=0 TO WH%-1 : t% = M%?I%: M%?I% = U%?I%: U%?I% = t% : NEXT I%
6250 PROCupdateScreenGrid(b%)
6260 PROCupdateBitmapFromGrid(b%)
6270 ENDPROC

6300 DEF PROCsaveUndo(b%)
6310 PROCcpbarr(G%+b%*WH%, U%, WH%)
6320 undo%=1
6330 ENDPROC

6399 REM ------ File Handling

6400 DEF PROCshowFilename(fn$)
6410 REM just display filename in status bar
6420 GCOL 0,15 : MOVE 0,FLINE%*8-4 : DRAW 320,FLINE%*8-4
6430 PRINT TAB(0,FLINE%);SPC(40);
6440 COLOUR 31 : PRINT TAB(0,FLINE%);"FILE:";TAB(6,FLINE%);fn$;
6450 ENDPROC

6500 DEF PROCclearStatusLine
6510 GCOL 0,15 : MOVE 0,FLINE%*8-4 : DRAW 320,FLINE%*8-4
6520 PRINT TAB(0,FLINE%);SPC(40);
6530 ENDPROC

6600 DEF PROCstatusMsg(Msg$,col%)
6610 Xpos%=40-LEN(Msg$)
6620 COLOUR col% : PRINT TAB(Xpos%,FLINE%);Msg$;
6630 ENDPROC

6700 DEF PROCloadSaveFile(SV%)
6710 fmt% = FNinputInt("Format 1)RGB8 2)RGBA8 3)RGBA2")
6720 IF fmt%<1 OR fmt%>3 THEN PROCclearStatusLine : ENDPROC
6730 yn$ = FNinputStr("Multiple Frames (y/N)")
6740 IF yn$ = "y" OR yn$ = "Y" THEN PROCmultiple(SV%, fmt%) : ENDPROC
6750 F$ = FNinputStr("Enter filename:")
6760 IF SV%=1 THEN PROCsaveDataFile(F$, BM%, fmt%) ELSE PROCloadDataFile(F$, BM%, fmt%)
6770 PROCshowFilename(F$)
6780 ENDPROC

6800 DEF PROCmultiple(SV%, fmt%)
6810 IF SV%=0 THEN PROCmultipleLoad(fmt%) ELSE PROCmultipleSave(fmt%)
6820 ENDPROC

6900 DEF FNgetFileName(pat$,nrepl%)
6910 nums%=INSTR(pat$,"%") : IF nums%=0 THEN =pat$ ELSE wcnt%=1
6920 IF INSTR(pat$,"%%")>0 THEN wcnt%=2
6930 IF INSTR(pat$,"%%%")>0 THEN wcnt%=3
6940 IF INSTR(pat$,"%%%%")>0 THEN wcnt%=4
6950 nstr$=RIGHT$("0000"+STR$(nrepl%),wcnt%)
6960 =LEFT$(pat$,nums%-1)+nstr$+MID$(pat$,nums%+wcnt%)

7000 DEF PROCmultipleLoad(fmt%)
7010 LOCAL Pattern$, NumFrames%, N%, start%
7020 NumFrames% = FNinputInt("Num frames to load:")
7030 IF NumFrames% <1 OR NumFrames%+BM% > NB% THEN PROCstatusMsg("Invalid",1) : ENDPROC
7040 Pattern$ = FNinputStr("Pattern eg f%%.dat")
7050 start% = FNinputInt("Files numbered from:")
7060 FOR N%=0 TO NumFrames%-1
7070 DestFrame%=N%+BM%
7080 PROCdrawBitmapBoxes(DestFrame%)
7090 F$ = FNgetFileName(Pattern$,start%+N%)
7100 COLOUR 7 : PRINT TAB(0,FLINE%);F$;
7110 PROCloadDataFile(F$, DestFrame%, fmt%)
7120 NEXT N%
7130 PROCupdateScreenGrid(BM%) 
7140 LFS%=BM%:LFE%=LFS%+NumFrames%-1 : SF%=LFS% : LoopDir%=1
7150 PROCdrawBitmapBoxes(BM%)
7160 ENDPROC 

7200 DEF PROCmultipleSave(fmt%)
7210 LOCAL Pattern$, NumFrames%, N%, FromFrame%, ToFrame%, start%
7220 FromFrame% = FNinputInt("From frame:") -1
7230 IF FromFrame%<0 OR FromFrame%>(NB%-1) THEN PROCstatusMsg("Invalid",1): ENDPROC
7240 ToFrame% = FNinputInt("To frame (incl):") -1
7250 IF ToFrame%<0 OR ToFrame%>(NB%-1) THEN PROCstatusMsg("Invalid",1): ENDPROC
7260 IF FromFrame%>ToFrame% THEN PROCstatusMsg("Invalid",1): ENDPROC
7270 Pattern$ = FNinputStr("Pattern eg f%%.dat")
7280 start% = FNinputInt("Files numbered from:") 
7290 NumFrames%=ToFrame%-FromFrame%+1
7300 FOR N%=0 TO NumFrames%-1
7310 F$ = FNgetFileName(Pattern$,start%+N%)
7320 PROCstatusMsg(F$,7)
7330 PROCsaveDataFile(F$, N%+FromFrame%, fmt%)
7340 NEXT N%
7350 ENDPROC 

7400 DEF PROCloadDataFile(f$, b%, fmt%)
7410 REM this loads file to internal memory and copies it out to the sprite
7420 LOCAL col%, I%, IND%
7430 PROCshowFilename(f$)
7440 FHAN%=OPENIN(f$)
7450 IF FHAN% = 0 THEN COLOUR 1:PRINT TAB(32,FLINE%);"No file"; : ENDPROC
7460 IF fmt%=1 sz%=(WH%*3)
7470 IF fmt%=2 sz%=(WH%*4)
7480 IF fmt%=3 sz%=(WH%*1)
7490 FLEN%=EXT#FHAN% : IF FLEN%<>sz% THEN PROCstatusMsg("Invalid",1): CLOSE#FHAN%: ENDPROC
7500 PROCstatusMsg("ok",10)
7510 CLOSE#FHAN%
7520 LSTR$="LOAD " + f$ + " " + STR$(MB%+graphics)
7530 OSCLI(LSTR$) : PROCstatusMsg("LOADED",10)
7540 IF fmt%=1 THEN PROCloadDataFile8bit(f$, b%, 0)
7550 IF fmt%=2 THEN PROCloadDataFile8bit(f$, b%, 1)
7560 IF fmt%=3 THEN PROCloadDataFile2bit(f$, b%)
7570 PROCstatusMsg("COPIED",10)
7580 PROCdrawGrid(BMW%,BMH%,GRIDX%,GRIDY%)
7590 PROCupdateBitmapFromGrid(b%)
7600 ENDPROC

7700 DEF PROCloadDataFile8bit(f$, b%, alpha%)
7710 LOCAL DATR%,DATG%,DATB%,IND%,I%,M%,col%,x%,y%
7720 PROCsaveUndo(b%)
7730 IF alpha%=1 THEN datw%=4 ELSE datw%=3
7740 M%=G%+WH%*b%
7750 FOR I%=0 TO (WH%)-1
7760 DATR% = ?(graphics+I%*datw%+0) DIV 85
7770 DATG% = ?(graphics+I%*datw%+1) DIV 85
7780 DATB% = ?(graphics+I%*datw%+2) DIV 85
7790 IND% = DATR% * 16 + DATG% * 4 + DATB% : REM RGB colour as index
7800 col% = REVLU%(IND%) : REM Reverse lookup of RGB colour to BBC Colour code
7810 M%?I% = col% : x%=I% MOD BMW% : y%=I% DIV BMW%
7820 PROCcsquare(1+GRIDX%+x%*8, 1+GRIDY%+y%*8, col%)
7830 NEXT I%
7840 ENDPROC

7900 DEF PROCloadDataFile2bit(f$, b%)
7910 LOCAL DATR%,DATG%,DATB%,IND%,I%,M%,col%,x%,y%
7920 PROCsaveUndo(b%)
7930 M%=G%+WH%*b%
7940 FOR I%=0 TO (WH%)-1
7950 IND% = FNrgb2TOind(?(graphics+I%))
7960 col% = REVLU%(IND%) : REM Reverse lookup of RGB colour to BBC Colour code
7970 M%?I% = col% : x%=I% MOD BMW% : y%=I% DIV BMW%
7980 PROCcsquare(1+GRIDX%+x%*8, 1+GRIDY%+y%*8, col%)
7990 NEXT I%
8000 ENDPROC

8100 DEF PROCsaveDataFile(f$, b%, fmt%)
8110 IF fmt%=1 THEN PROCsaveDataFile8bit(f$, b%, 0)
8120 IF fmt%=2 THEN PROCsaveDataFile8bit(f$, b%, 1)
8130 IF fmt%=3 THEN PROCsaveDataFile2bit(f$, b%)
8140 ENDPROC

8200 DEF PROCsaveDataFile8bit(f$, b%, alpha%)
8210 REM save raw data to a file. RGB or RGBA 8bit format with no header.
8220 LOCAL I%, RGBIndex%, h%, a%
8230 M%=G%+WH%*b%
8240 h% = OPENOUT(f$)
8250 IF h%=0 THEN PRINT TAB(20,FLINE%);"Failed to open file"; : ENDPROC
8260 FOR I%=0 TO (WH%)-1
8270 RGBIndex% = CL%(M%?I%) : REM lookup the RGB colour index for this colour 
8280 BPUT#h%, FNindTOrgb(RGBIndex%,0)
8290 BPUT#h%, FNindTOrgb(RGBIndex%,1)
8300 BPUT#h%, FNindTOrgb(RGBIndex%,2)
8305 a%=&FF
8310 IF alpha%=1 AND TRANSP%=M%?I% THEN a%=&00
8315 IF alpha%=1 THEN BPUT#h%, a%
8320 NEXT
8330 CLOSE#h%
8340 ENDPROC

8400 DEF PROCsaveDataFile2bit(f$, b%)
8410 REM save raw data to a file. RGBA2222 format with no header.
8420 LOCAL I%, RGBIndex%, h%
8430 M%=G%+WH%*b%
8440 h% = OPENOUT(f$)
8450 IF h%=0 THEN PRINT TAB(20,FLINE%);"Failed to open file"; : ENDPROC
8460 FOR I%=0 TO (WH%)-1
8470 RGBIndex% = CL%(M%?I%) : REM lookup the RGB colour index for this colour 
8480 out% = FNindTOrgb2(RGBIndex%)
8485 IF TRANSP%=M%?I% THEN out% = out% AND &3F
8490 BPUT#h%, out%
8500 NEXT
8510 CLOSE#h%
8520 ENDPROC

8600 DEF PROCexportData8bit(f$, b%, ln%, alpha%)
8610 LOCAL I%, RGBIndex%, h%, J%, PPL%, a%
8620 PPL%=8 
8630 SS$=STRING$(250," ") 
8640 SS$=STR$(ln%)+" REM "+f$+" "+STR$(BMW%)+"x"+STR$(BMH%)+" "
8650 IF alpha%=1 THEN SS$=SS$+" 4 bytes pp RGBA" ELSE SS$=SS$+" 3 bytes pp RGB" 
8660 SS$=SS$+" bitmap num "+STR$(b%+1)
8670 ln%=ln%+10
8680 h% = OPENUP(f$) : IF h%=0 THEN h% = OPENOUT(f$) ELSE PTR#h%=EXT#h% 
8690 IF h%=0 THEN PROCstatusMsg("Failed to open",1): ENDPROC
8700 M%=G%+WH%*b%
8710 FOR I%=0 TO (WH%)-1
8720 IF I% MOD PPL% = 0 THEN PROCprintFileLine(h%,SS$) : SS$=STR$(ln%)+" DATA " : ln%=ln%+10
8730 RGBIndex% = CL%(M%?I%) : REM lookup the RGB colour index for this colour 
8740 FOR J%=0 TO 2
8750 IF FNindTOrgb(RGBIndex%,J%)=0 THEN SS$ = SS$+"0" ELSE SS$ = SS$+"&"+STR$~(FNindTOrgb(RGBIndex%,J%))
8760 IF J%<2 THEN SS$=SS$+","
8770 NEXT J%
8775 a%=&FF : IF alpha%=1 AND TRANSP%=M%?I% THEN a%=0
8780 IF alpha%=1 THEN SS$=SS$+",&"+STR$~(a%)
8790 IF I% MOD PPL% < (PPL%-1) THEN SS$=SS$+","
8800 NEXT I%
8810 PROCprintFileLine(h%, SS$)
8820 CLOSE#h%
8830 ENDPROC

8900 DEF PROCexportData2bit(f$,b%,ln%)
8910 LOCAL PIX%,PPL%,SS$,I%,J%,col%
8920 PIX%=0
8930 PPL%=16
8940 SS$=STRING$(250," ") 
8950 SS$=STR$(ln%)+" REM "+f$+" "+STR$(BMW%)+"x"+STR$(BMH%)+" 1 byte pp RGBA2222" 
8960 SS$=SS$+" bitmap num "+STR$(b%+1)
8970 ln%=ln%+10
8980 h% = OPENUP(f$) : IF h%=0 THEN h% = OPENOUT(f$) ELSE PTR#h%=EXT#h% 
8990 IF h%=0 THEN PROCstatusMsg("Failed to open",1) : ENDPROC
9000 M%=G%+WH%*b%
9010 FOR I%=0 TO (WH%)-1
9020 IF I% MOD PPL% = 0 THEN PROCprintFileLine(h%,SS$) : SS$=STR$(ln%)+" DATA " : ln%=ln%+10
9030 RGBIndex% = CL%(M%?I%) : REM lookup the RGB colour index for this colour 
9040 PIX%=RGBIndex%
9050 IF RGBIndex%>0 AND TRANSP%<>M%?I% THEN PIX%=PIX% OR &C0 : REM alpha=1
9060 IF PIX%=0 THEN SS$=SS$+"0" ELSE SS$=SS$+"&"+STR$~(PIX%)
9070 IF I% MOD PPL% < (PPL%-1) THEN SS$=SS$+","
9080 NEXT I%
9090 PROCprintFileLine(h%, SS$)
9100 CLOSE#h%
9110 ENDPROC

9200 DEF PROCexport
9210 LOCAL frames% : frames%=1
9220 fmt% = FNinputInt("Format 1)RGB8 2)RGBA8 3)RGBA2")
9230 IF fmt%<1 OR fmt%>3 THEN ENDPROC
9240 FromFrame% = FNinputInt("From frame:") -1
9250 IF FromFrame%<0 OR FromFrame%>(NB%-1) THEN PROCstatusMsg("Invalid",1): ENDPROC
9260 ToFrame% = FNinputInt("To frame (incl):") -1
9270 IF ToFrame%<0 OR ToFrame%>(NB%-1) THEN PROCstatusMsg("Invalid",1): ENDPROC
9280 IF FromFrame%>ToFrame% THEN PROCstatusMsg("Invalid",1): ENDPROC
9290 F$ = FNinputStr("Enter filename:")
9300 IF F$ = "" THEN PROCshowFilename(F$) : ENDPROC
9310 Line% = FNinputInt("Line number:")
9320 FOR bmid%=FromFrame% TO ToFrame% 
9330 COLOUR 10:PRINT TAB(30,FLINE%);"bm=";STR$(bmid%+1);
9340 IF fmt%=1 THEN PROCexportData8bit(F$, bmid%, Line%, 0): Line%=Line%+20*BMW%+10
9350 IF fmt%=2 THEN PROCexportData8bit(F$, bmid%, Line%, 1): Line%=Line%+20*BMW%+10
9360 IF fmt%=3 THEN PROCexportData2bit(F$,bmid%,Line%): Line%=Line%+10*BMW%+10 
9370 NEXT bmid%
9380 COLOUR 10:PRINT TAB(37,FLINE%);"ok";
9390 ENDPROC

9500 DEF PROCprintFileLine(FH%, S$)
9510 REM dos line endings
9520 PRINT#FH%,S$ : BPUT#FH%,10
9530 ENDPROC

9600 REM ------- Generic Functions

9700 DEF PROCfilledRect(x%,y%,w%,h%,c%)
9710 REM assume screen scaling OFF
9720 GCOL 0,c%
9730 MOVE x%,y% 
9740 PLOT 101, x%+w%, y%+h%
9750 ENDPROC

9800 DEF PROCrect(x%,y%,w%,h%,c%)
9810 REM assume screen scaling is OFF
9820 GCOL 0,c%
9830 MOVE x%,y% 
9840 DRAW x%+w%,y% 
9850 DRAW x%+w%, y%+h%
9860 DRAW x%, y%+h% 
9870 DRAW x%, y%
9880 ENDPROC

9900 DEF FNinputStr(prompt$)
9910 PRINT TAB(0,FLINE%);SPC(40);
9920 COLOUR 31 : PRINT TAB(0,FLINE%);prompt$; : COLOUR 15 : INPUT s$
9930 =s$

10000 DEF FNinputInt(prompt$)
10010 PRINT TAB(0,FLINE%);SPC(40);
10020 COLOUR 31 : PRINT TAB(0,FLINE%);prompt$; : COLOUR 15 : INPUT i%
10030 =i%

10100 DEF PROCconfig(conf_file$)
10110 VDU 23,0,192,0,23,1,0 : REM logical screen, cursor off
10120 PROCreadConfigFile(conf_file$)
10130 ENDPROC

10200 DEF PROCreadConfigFile(f$)
10210 ch%=OPENIN(f$)
10220 C. 7 : PRINT TAB(0,2);f$;": "; : IF ch%=0 THEN C. 9:PRINT "No file"; : ENDPROC
10230 REPEAT
10240 skip=0 : epos=0
10250 INPUT#ch%,s$
10260 IF MID$(s$,1,1)="#" skip=1
10270 IF skip=0 THEN r%=INSTR(s$,CHR$(&0A)) IF r%>0 THEN  s$=MID$(s$,r%+1)
10280 IF skip=0 THEN epos=INSTR(s$,"=")
10290 IF skip=0 AND epos>0 THEN var$=MID$(s$,1,epos-1) : val$=MID$(s$,epos+1)
10300 IF skip=0 AND epos>0 THEN PROCsetConfigVar(var$, val$)
10310 UNTIL EOF#ch%
10320 CLOSE#ch%
10330 ENDPROC

10400 DEF PROCsetConfigVar(var$, val$)
10410 REM PRINT "VAR:";var$;" VAL:";val$
10420 IF var$="JOY" THEN CONFIG_JOY=VAL(val$)
10430 IF var$="SIZE" THEN CONFIG_SIZE=VAL(val$)
10440 IF var$="JOYDELAY" THEN CONFIG_JOYDELAY=VAL(val$)
10450 IF var$="C1" THEN C1=VAL(val$)
10460 IF var$="C2" THEN C2=VAL(val$)
10470 IF var$="BM_MAX" THEN BM_MAX=VAL(val$)
10480 ENDPROC

10500 DEF FNinputOpts2(line%,base$,hili%,opt1$,opt2$)
10510 C. C1: PRINT TAB(0,line%);base$;" ";
10520 IF hili%=1 THEN COLOUR 15
10530 PRINT "1) ";opt1$;" ";
10540 C. C1
10550 IF hili%=2 THEN COLOUR 15
10560 PRINT "2) ";opt2$;" ";
10570 COLOUR 15 : INPUT in%
10580 =in% 

10600 DEF PROCsetupChars
10610 VDU 23,240,0,&20,&40,&FF,&40,&20,0,0 : REM left arrow
10620 VDU 23,241,0,&24,&42,&FF,&42,&24,0,0 : REM bidirectional
10630 VDU 23,242,0,&04,&02,&FF,&02,&04,0,0 : REM right 
10640 VDU 23,243,&10,&38,&54,&10,&10,&10,&10,0 : REM up 
10650 VDU 23,244,&10,&10,&10,&10,&54,&38,&10,0 : REM down 
10660 ENDPROC

10700 REM -------  block functions 

10800 DEF PROCmarkBlock
10810 IF BSstate%=0 THEN BSstate%=1 : HaveBlock%=0
10820 IF BSstate%=1 THEN BSrect%(0)=PX% : BSrect%(1)=PY% : BSrect%(2)=PX% : BSrect%(3)=PY%
10830 IF BSstate%=2 THEN BSrect%(2)=PX% : BSrect%(3)=PY%
10840 BSstate% = BSstate%+1 : IF BSstate%=3 THEN BSstate%=0
10850 ENDPROC

10900 DEF PROCdoBlockFill(c%,b%)
10910 LOCAL x%,y%,M%
10920 M%=G%+WH%*b%
10930 PROCsaveUndo(b%)
10940 FOR y%=BSrect%(1) TO BSrect%(3)
10950 FOR x%=BSrect%(0) TO BSrect%(2)
10960 M%?(x%+BMW%*y%)=c%
10970 PROCcsquare(1+GRIDX%+x%*8, 1+GRIDY%+y%*8, c%)
10980 NEXT x% : NEXT y%
10990 PROCupdateBitmapFromGrid(b%)
11000 ENDPROC

11100 DEF PROCblockCursor(switch%)
11110 LOCAL col%, xdiff%, ydiff%, x0%,y0%,x1%,y1%
11120 IF BSstate%=0 THEN ENDPROC
11130 BSrect%(2)=PX% : BSrect%(3)=PY% : REM new curs pos
11140 x0%=BSrect%(0) : y0%=BSrect%(1) : x1%=BSrect%(2) : y1%=BSrect%(3)
11150 IF BSrect%(0) > BSrect%(2) THEN BSstate%=0 : PROCgridCursor(1) :ENDPROC
11160 IF BSrect%(1) > BSrect%(3) THEN BSstate%=0 : PROCgridCursor(1) :ENDPROC
11170 xdiff% = x1%-x0% 
11180 ydiff% = y1%-y0%
11190 IF switch%=0 THEN col%=GRIDCOL% ELSE col%=COL%
11200 PROCrect(GRIDX%+x0%*8, GRIDY%+y0%*8, 8*(xdiff%+1), 8*(ydiff%+1), col%)
11210 ENDPROC

11300 DEF PROCblockFill(c%,b%)
11310 IF BSstate%=0 THEN ENDPROC
11320 IF BSstate%=2 THEN BSrect%(2)=PX% : BSrect%(3)=PY%
11330 IF BSstate%=2 THEN PROCdoBlockFill(c%,b%) : PROCblockCursor(0)
11340 BSstate%=0
11350 ENDPROC

11400 DEF PROCcopyBlock(b%)
11410 LOCAL x%,y%,xx%,yy%,M%
11420 IF BSstate%=0 THEN ENDPROC
11430 IF BSstate%=2 THEN BSrect%(2)=PX% : BSrect%(3)=PY%
11440 M%=G%+WH%*b%
11450 FOR y%=BSrect%(1) TO BSrect%(3)
11460 FOR x%=BSrect%(0) TO BSrect%(2)
11470 xx%=x%-BSrect%(0) : yy%=y%-BSrect%(1)
11480 BLOCK%(xx%+BMW%*yy%)=M%?(x%+BMW%*y%)
11490 NEXT x% : NEXT y%
11500 BlockW%=BSrect%(2)-BSrect%(0)+1
11510 BlockH%=BSrect%(3)-BSrect%(1)+1
11520 HaveBlock%=1 : BSstate%=0
11530 ENDPROC

11600 DEF PROCcopyImage(b%)
11610 LOCAL I%,M%
11620 M%=G%+WH%*b%
11630 FOR I%=0 TO WH%-1 : BLOCK%(I%)=M%?I% : NEXT I%
11640 BlockW%=BMW% : BlockH%=BMH%
11650 HaveBlock%=1 : BSstate%=0
11660 ENDPROC

11700 DEF PROCpasteBlock(b%)
11710 LOCAL x%,y%,xx%,yy%,M%
11720 M%=G%+WH%*b%
11730 PROCsaveUndo(b%)
11740 IF HaveBlock%=0 THEN ENDPROC
11750 FOR y%=0 TO BlockH%-1
11760 FOR x%=0 TO BlockW%-1
11770 xx%=x%+PX% : yy%=y%+PY%
11780 IF xx%<BMW% AND yy%<BMH% THEN M%?(xx%+BMW%*yy%)=BLOCK%(x%+BMW%*y%)
11790 IF xx%<BMW% AND yy%<BMH% THEN PROCcsquare(1+GRIDX%+xx%*8, 1+GRIDY%+yy%*8, BLOCK%(x%+y%*BMH%))
11800 NEXT x% : NEXT y%
11810 PROCupdateBitmapFromGrid(b%)
11820 ENDPROC

11900 DEF PROCmirrorSelected(x1%,y1%,x2%,y2%,b%)
11910 REM flips left-right
11920 LOCAL x%,y%,t%,bw%,ic%,io%,M%
11930 M%=G%+WH%*b%
11940 PROCsaveUndo(b%)
11950 bw%=x2%-x1%+1
11960 FOR y%=y1% TO y2%
11970 FOR x%=x1% TO x1%+(bw% DIV 2)-1
11980 ic%=x%+BMW%*y% : REM current
11990 io%=(x2%-x%+x1%)+BMW%*y% : REM opposite
12000 t%=M%?ic% : M%?ic%=M%?io% : M%?io%=t% : REM SWAP
12010 NEXT x% : NEXT y%
12020 REM BSstate%=0
12030 PROCupdateBitmapFromGrid(b%) : PROCupdateScreenGrid(b%)
12040 ENDPROC

12100 DEF PROCflipSelected(x1%,y1%,x2%,y2%,b%)
12110 REM flips up-down
12120 LOCAL x%,y%,t%,bw%,ic%,io%,M%
12130 M%=G%+WH%*b%
12140 PROCsaveUndo(b%)
12150 bh%=y2%-y1%+1
12160 FOR x%=x1% TO x2%
12170 FOR y%=y1% TO y1%+(bh% DIV 2)-1
12180 ic%=x%+BMW%*y% : REM current
12190 io%=x%+BMW%*(y2%-y%+y1%) : REM opposite
12200 t%=M%?ic% : M%?ic%=M%?io% : M%?io%=t% : REM SWAP
12210 NEXT y% : NEXT x%
12220 REM BSstate%=0
12230 PROCupdateBitmapFromGrid(b%) : PROCupdateScreenGrid(b%)
12240 ENDPROC

12300 DEF PROCrotateSelected(d%,x1%,y1%,x2%,y2%,b%)
12310 REM rotate
12320 LOCAL x%,y%,bw%,bh%,i%, ic%,ir%,M%
12330 bw%=x2%-x1%+1 : bh%=y2%-y1%+1
12340 IF bw% <> bh% THEN PROCstatusMsg("not square",1) : ENDPROC
12350 M%=G%+WH%*b%
12360 PROCsaveUndo(b%)
12370 PROCcpbarr(M%, R%, WH%)
12380 FOR y%=y1% TO y2%
12390 FOR x%=x1% TO x2%
12400 ic%=x%+y%*BMW%
12410 IF d%=0 THEN ir%=(x2%-(y%-y1%)) + (y1%+(x%-x1%))*BMW%: REM ccw
12420 IF d%=1 THEN ir%=(x1%+(y%-y1%)) + (y2%-(x%-x1%))*BMW%: REM cw
12430 R%?ir%=M%?ic%
12440 NEXT x% : NEXT y%
12450 PROCcpbarr(R%,M%,WH%)
12460 REM BSstate%=0
12470 PROCupdateBitmapFromGrid(b%) : PROCupdateScreenGrid(b%)
12480 ENDPROC

12500 REM -------  Flood fill 

12600 DEF PROCfloodFill(x%,y%,c%,b%)
12610 LOCAL i%, ii%, bcol%, M%
12620 M%=G%+WH%*b%
12630 PROCsaveUndo(b%)
12640 i%=x%+BMW%*y%
12650 bcol%=M%?i% : REM background colour to fill
12660 FFlen%=1 : FF%(FFlen%-1)=i%
12670 REPEAT 
12680 ii%=FNnextItemFF
12690 IF ii% > -1 THEN PROCdoFloodFill(ii%,bcol%,c%,b%)
12700 UNTIL FFlen%=0
12710 PROCupdateBitmapFromGrid(b%) : REM PROCupdateScreenGrid(b%)
12720 ENDPROC

12800 DEF FNnextItemFF
12810 IF FFlen%=0 THEN =-1
12820 FFlen%=FFlen%-1 
12830 =FF%(FFlen%)

12900 DEF FNaddItemFF(item%)
12910 IF FFlen%=FFlenMAX% THEN =-1
12920 FF%(FFlen%)=item% : FFlen%=FFlen%+1 
12930 =FFlen%

13000 DEF PROCdoFloodFill(i%,bcol%,c%,b%)
13010 LOCAL xx%,yy%,ret%,M%
13020 xx%=i% MOD BMW% : yy%=i% DIV BMW%
13030 M%=G%+WH%*b%
13040 M%?i%=c% 
13050 PROCcsquare(1+GRIDX%+xx%*8, 1+GRIDY%+yy%*8, c%)
13060 IF xx%>0 THEN IF M%?(i%-1) = bcol% THEN ret%=FNaddItemFF(i%-1) : REM left
13070 IF ret%=-1 THEN STOP
13080 IF xx%<(BMW%-1) THEN IF M%?(i%+1) = bcol% THEN ret%=FNaddItemFF(i%+1)  : REM right
13090 IF ret%=-1 THEN STOP
13100 IF yy%>0 THEN IF M%?(i%-BMW%) = bcol% THEN ret%=FNaddItemFF(i%-BMW%) : REM up
13110 IF ret%=-1 THEN STOP
13120 IF yy%<(BMH%-1) THEN IF M%?(i%+BMW%) = bcol% THEN ret%=FNaddItemFF(i%+BMW%) : REM down
13130 IF ret%=-1 THEN STOP
13140 ENDPROC

13600 DEF PROCwbarr(p%,l%,v%)
13610 REM write byte array. Dest DE, Length CB
13620 LOCAL x%
13630 FOR x%=0 TO l%-1 : p%?x% = v% : NEXT
13640 ENDPROC

13700 DEF PROCcpbarr(s%,d%,l%)
13710 REM copy byte array from s% (HL) to d% (DE), len l%
13720 LOCAL x%
13730 FOR x%=0 TO l%-1 : d%?x% = s%?x% : NEXT
13740 ENDPROC

13800 REM ------- Colour lookup Functions ------------
13810 :

13900 DEF PROCloadLUT
13910 REM Load the RGB Look up table
13920 REM CL%() is BBC Col to RGBIndex
13930 REM RGB%() is a packed array of the RGB colours
13940 REM REVLU%() is a reverse lookup table to get the colour  
13950 LOCAL I%
13960 RESTORE 14360
13970 FOR I%=0 TO 63 
13980 READ CL%(I%)
13990 NEXT
14000 FOR I%=0 TO 63
14010 READ REVLU%(I%)
14020 NEXT
14030 ENDPROC

14100 DEF FNindTOrgb2(ind%) : REM convert an rgb index to RGB2
14110 LOCAL b%,g%,r%
14120 b%=(ind% AND &03)
14130 g%=(ind% AND &0C) DIV 4
14140 r%=(ind% AND &30) DIV 16
14150 =&C0 OR (b%*16) OR (g%*4) OR r%

14200 DEF FNindTOrgb(ind%,comp%) : REM convert rgb index to RGB comp. 0=R,1=G,2=B
14210 IF comp%=0 THEN tb%=(ind% AND &30) DIV 16
14220 IF comp%=1 THEN tb%=(ind% AND &0C) DIV 4 
14230 IF comp%=2 THEN tb%=ind% AND &03
14240 =TTE%(tb%)

14300 DEF FNrgb2TOind(val%)
14310 ind%=((val% AND &30) DIV 16)
14320 ind%=ind% OR (val% AND &0C)
14330 ind%=ind% OR ((val% AND &03) * 16)
14340 =ind%
14350 REM Colour mapping to RGB 
14360 REM LABEL_data1:
14370 DATA &00, &20, &08, &28, &02, &22, &0A, &2A
14380 DATA &15, &30, &0C, &3C, &03, &33, &0F, &3F
14390 DATA &01, &04, &05, &06, &07, &09, &0B, &0D
14400 DATA &0E, &10, &11, &12, &13, &14, &16, &17
14410 DATA &18, &19, &1A, &1B, &1C, &1D, &1E, &1F
14420 DATA &21, &23, &24, &25, &26, &27, &29, &2B
14430 DATA &2C, &2D, &2E, &2F, &31, &32, &34, &35
14440 DATA &36, &37, &38, &39, &3A, &3B, &3D, &3E
14450 REM - RGB reverse map to colour
14460 DATA  0, 16,  4, 12, 17, 18, 19, 20,  2, 21,  6, 22, 10, 23, 24, 14
14470 DATA 25, 26, 27, 28, 29,  8, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39
14480 DATA  1, 40,  5, 41, 42, 43, 44, 45,  3, 46,  7, 47, 48, 49, 50, 51
14490 DATA  9, 52, 53, 13, 54, 55, 56, 57, 58, 59, 60, 61, 11, 62, 63, 15

14600 DEF PROCloadBitshiftTable
14610 REM lookup table for BitShift for RGBA2222 (don't have nice bit-shift operators)
14620 LOCAL col%,comp%
14630 RESTORE 14730
14640 FOR comp%=0 TO 3 : FOR col%=0 TO 3
14650 READ BSTAB%(col%,comp%) 
14660 NEXT col% : NEXT comp%
14670 REM Two-bit TO Eight-bit convert
14680 FOR comp%=0 TO 3
14690 READ TTE%(comp%)
14700 NEXT comp%
14710 ENDPROC
14720 REM bitshift lookup 
14730 REM LABEL_data2:
14740 DATA 0,1,2,3, 0,4,8,&0C, 0,&10,&20,&30, 0,&40,&80,&C0
14750 DATA 0,&55,&AA,&FF

14800 REM ------------ colour squares -------------
14810 REM Use filled rect.

14900 DEF PROCcsquare(x%,y%,c%)
14910 PROCfilledRect(x%,y%,6,6,c%)
14920 ENDPROC

15000 REM  ------------ Error Handling -------------
15010 REM LABEL_error:
15020 VDU 23, 0, 192, 1 : REM turn on normal logical screen scaling
15030 VDU 23, 1, 1 : REM enable text cursor
15040 @%=&90A
15050 COLOUR 15
15060 IF ISEXIT=0 PRINT:REPORT:PRINT " @ line ";ERL:END
15070 PRINT : PRINT "Goodbye"
