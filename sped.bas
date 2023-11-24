10 REM Sprite editor for the Agon Light and Console 8 by Assif (robogeekoid)
15 VERSION$="v0.18"
20 ON ERROR GOTO 10000
25 DIM graphics 1024 : REM memory for file load 
26 IF HIMEM>65536 THEN ADL=1 ELSE ADL=0 : REM 24-bit addr basic
27 IF ADL=1 THEN MB%=0 ELSE MB%=&40000
30 MODE 8
35 ISEXIT=0 : SW%=320 : SH%=240 
37 REM ----- config in sped.ini -----
40 CONFIG_SIZE=1 : CONFIG_JOY=0 : CONFIG_TYPE=0
42 CONFIG_JOYDELAY=20
44 DIM FEXT$(3) : FEXT$(1)=".rgb" : FEXT$(2)=".rgba" : FEXT$(2)=".dat" 
46 C1=21: C2=19: REM Help colours (C1=highlight)
50 PROCconfig("sped.ini")
52 IF CONFIG_SIZE=2 THEN W%=8 : H%=8 ELSE W%=16 : H%=16
55 REM --------------------------------
57 GRIDX%=8 : GRIDY%=16 : REM Grid position
60 GRIDCOL%=8 : CURSCOL%=15
65 SCBOXX%=170 : SCBOXY%=148 : REM shortcut box pos
70 DIM CL%(64) : DIM REVLU%(64) : PROCloadLUT
75 DIM BSTAB%(3,3), TTE%(4) : PROCloadBitshiftTable

80 PALX%=8 : PALY%=146 : PALW%=16 : PALH%=4 : REM palette x/y,w/h 
82 COL%=1 : REM selected palette colour
84 PX%=0 : PY%=0 : REM position
86 BSstate%=0 : DIM BSrect%(4) : REM block select
87 HaveBlock%=0 : DIM BLOCK%(W%*H%) : BlockW%=0:BlockH%=0 : REM copied block

100 DIM KEYG(4), KEYP(4) : REM in order left, right, up down 
105 KEY_SET=32 : KEY_DEL=127 : PROCsetkeys
110 FLINE%=24 : REM FLINE is line on which filename appears
115 F$=STRING$(20," ") 
120 DIM SKey%(9) : FOR I%=0 TO 9 : SKey%=-1 : NEXT I%

130 REM multi-bitmap sprite setup
135 NumBitmaps% = 7 : BM% = 0 : REM current bitmap
140 NSF% = 1 : SF%=0 : REM Number of sprite frames and current frame
144 SpriteDelay%=10 : Ctr%=SpriteDelay%
146 LoopType%=0 : REM 0=left to right loop, 1=ping-pong
148 LoopDir%=1

155 SPX%=150 : SPY%=18 : REM sprite x/y position on screen
157 BBOXX%=150 : BBOXY%=42 : REM top-left of bitmap boxes
160 DIM BMX%(NumBitmaps%), BMY%(NumBitmaps%)
165 FOR I%=0 TO NumBitmaps%-1 : BMX%(I%)=BBOXX% + 24*I% : BMY%(I%)=BBOXY% : NEXT

170 REM declare data for grid
175 DIM G%(W%*H%, NumBitmaps%) 
176 DIM U%(W%*H%) : REM for a simple, one level Undo
177 FFlenMAX%=W%*H% : DIM FF%(W%*H%) : FFlen%=0 : REM stack for flood fill
178 DIM R%(W%*H%) : REM rotation work area

180 PROCdrawScreen
182 COLOR 15 : PRINT TAB(12,FLINE%);"LOADING";
185 PROCcreateSprite(W%,H%)

190 FOR B%=0 TO NumBitmaps%-1
195 FOR I%=0 TO W%*H%-1 : G%(I%, B%)=0 : U%(I%)=0 : NEXT I%
200 NEXT B%

210 FOR B%=0 TO NumBitmaps%-1 : PROCupdateBitmapFromGrid(B%) : NEXT

230 COLOR 15 : PRINT TAB(12,FLINE%);"       ";

240 REM Main Loop
250 REPEAT
260 key=INKEY(0)
265 IF CONFIG_JOY=1 JOY=GET(158) : BUTTON=GET(162) ELSE JOY=0 : BUTTON=0
267 IF CONFIG_JOY=0 AND key=-1 GOTO 600
270 IF key=-1 AND JOY=255 AND BUTTON=247 GOTO 600 : REM skip to Until
280 PROCgridCursor(0) : PROCblockCursor(0)
290 IF key = ASC("x") OR key=ASC("X") ISEXIT=1 : REM x=exit
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
410 IF key = 32 OR key = 13 THEN PROCsetCol(PX%,PY%,COL%)
415 IF BUTTON=215 THEN PROCsetCol(PX%,PY%,COL%)
420 IF key = 127  THEN PROCsetCol(PX%,PY%,0)
430 IF (key = ASC("c") OR key=ASC("C")) AND BSstate%=0 THEN PROCclearGrid(0, BM%)
435 IF (key = ASC("c") OR key=ASC("C")) AND BSstate%>0 THEN PROCblockFill(0, BM%)
440 IF (key = ASC("f") OR key=ASC("F")) AND BSstate%=0 THEN PROCclearGrid(COL%, BM%)
445 IF (key = ASC("f") OR key=ASC("F")) AND BSstate%>0 THEN PROCblockFill(COL%, BM%)
450 IF key = ASC("p") OR key=ASC("P") THEN PROCpickCol
455 IF key = ASC("b") OR key=ASC("B") THEN PROCmarkBlock 
460 REM V=save L=load
470 IF key = ASC("l") OR key=ASC("L") THEN PROCloadSaveFile(0)
480 IF key = ASC("v") OR key=ASC("V") THEN PROCloadSaveFile(1) : REM V=saVe file 
490 IF key = ASC("e") OR key = ASC("E") THEN PROCexport
495 REM M,N select bitmap
500 IF key = ASC(".") OR key=ASC(">") THEN BM%=(BM%+1) MOD NumBitmaps% : PROCdrawBitmapBoxes : PROCupdateScreenGrid(BM%)
510 IF key = ASC(",") OR key=ASC("<") THEN BM%=(BM%-1) : IF BM%<0 THEN BM%=NumBitmaps%-1
520 IF key = ASC(",") OR key=ASC("<") THEN PROCdrawBitmapBoxes : PROCupdateScreenGrid(BM%)
530 IF key = ASC("k") OR key=ASC("K") THEN PROCsetShortcutKey
535 REM Palette shortcut key, frames select and Loop/cycle type
540 IF key >= ASC("1") AND key <= ASC("9") THEN IF SKey%(key-48)>=0 THEN PROCselectPaletteCol(SKey%(key-48))
550 IF key = ASC("r") OR key = ASC("R") THEN PROCsetFrames
555 IF key = ASC("o") OR key = ASC("O") THEN PROCtoggleLoopType
560 IF key = ASC("i") OR key = ASC("I") THEN PROCsetLoopSpeed
562 IF key = ASC("-") AND BSstate%=0 THEN PROCcopyImage(BM%)
564 IF key = ASC("-") AND BSstate%>0 THEN PROCcopyBlock(BM%)
570 IF key = ASC("=") AND HaveBlock%=1 THEN PROCpasteBlock(BM%)
572 IF key = ASC("#") AND BSstate%=0 THEN PROCmirrorSelected(0,0,W%-1,H%-1,BM%)
574 IF key = ASC("#") AND BSstate%>0 THEN PROCmirrorSelected(BSrect%(0),BSrect%(1),BSrect%(2),BSrect%(3),BM%)
576 IF key = ASC("~") AND BSstate%=0 THEN PROCflipSelected(0,0,W%-1,H%-1,BM%)
578 IF key = ASC("~") AND BSstate%>0 THEN PROCflipSelected(BSrect%(0),BSrect%(1),BSrect%(2),BSrect%(3),BM%)
580 IF key = ASC("u") OR key = ASC("U") THEN PROCdoUndo(BM%)
582 IF key = ASC("/") THEN PROCfloodFill(PX%,PY%,COL%,BM%)
584 IF key = ASC("]") AND BSstate%=0 THEN PROCrotateSelected(0,0,0,W%-1,H%-1,BM%)
585 IF key = ASC("]") AND BSstate%>0 THEN PROCrotateSelected(0,BSrect%(0),BSrect%(1),BSrect%(2),BSrect%(3),BM%)
586 IF key = ASC("[") AND BSstate%=0 THEN PROCrotateSelected(1,0,0,W%-1,H%-1,BM%)
587 IF key = ASC("[") AND BSstate%>0 THEN PROCrotateSelected(1,BSrect%(0),BSrect%(1),BSrect%(2),BSrect%(3),BM%)
590 PROCshowFilename("")
592 PROCprintSecondHelp(26)
594 PROCgridCursor(1) : PROCblockCursor(1)

600 REM Nokey GOTO comes here
610 PROCshowSprite
620 UNTIL ISEXIT = 1
630 GOTO 10000

695 END

699 REM ------ Static Screen Update Functions

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
779 PROCsetupChars
780 PROCprintTitle
782 PROCprintHelp
784 PROCshowFilename("")
786 COLOUR 15
795 ENDPROC

800 DEF PROCprintHelp
802 GCOL 0,15 : MOVE 0,26*8-4 : DRAW 320,26*8-4
804 PROCprintMainHelp(26)
806 PROCprintSecondHelp(26)
808 PROCprintBitmapHelp(19,10)
809 COLOUR 54 : PRINT TAB(36,12);CHR$(240+LoopType%)
810 PROCshortcutBox
820 ENDPROC

830 DEF PROCshort(x,y,pre$,hi$,post$)
833 PRINT TAB(x,y);
834 C. C2: PRINT pre$;
837 C. C1: PRINT hi$;
838 C. C2: PRINT post$;
840 ENDPROC

850 DEF PROCprintMainHelp(v%)
852 C. C1 : PRINT TAB(0,v%+0);:VDU 240,243,244,242: C. C2: PRINT TAB(5,v%+0);"Move";
854 C. C1 : PRINT TAB(0,v%+1);"WASD";:   C. C2: PRINT TAB(5,v%+1);"Color";
856 C. C1 : PRINT TAB(0,v%+2);"Spc";:    C. C2: PRINT TAB(5,v%+2);"Set";
858 C. C1 : PRINT TAB(0,v%+3);"Bksp";:   C. C2: PRINT TAB(5,v%+3);"Del";
860 GCOL 0,15 : MOVE 10*8+4,26*8 : DRAW 10*8+4,31*8+2
865 ENDPROC

880 DEF PROCprintSecondHelp(v%)
882 PROCshort(11,v%,"","L","oad"): PROCshort(17,v%,"sa","V","e"): PROCshort(23,v%,"","E","xport"): PROCshort(30,v%,"","U","ndo"):  PROCshort(36,v%,"e","X","it")
884 PROCshort(11,v%+1,"","P","ick"): PROCshort(17,v%+1,"","C","lear"): PROCshort(23,v%+1,"","F","ill") : PROCshort(30,v%+1,"","/","flood")
888 PROCshort(11,v%+2,"","B","lock") 
890 PROCshort(17,v%+2,"","-","copy")
892 IF HaveBlock% THEN PROCshort(23,v%+2,"","=","paste") ELSE C.8:PRINT TAB(23,v%+2);"=paste";
894 PROCshort(23,v%+3,"","~","flip") : PROCshort(30,v%+3,"","#","mirror")
896 PROCshort(11,v%+3,"","[]","rotate") 
900 ENDPROC

910 DEF PROCshortcutBox
920 COLOUR 7 : FOR I%=1 TO 9 : PRINT TAB((SCBOXX% DIV 8) -1 +I%*2,SCBOXY% DIV 8 +1 );I% : NEXT
922 COLOUR 8 : PRINT TAB((SCBOXX% DIV 8) +1,SCBOXY% DIV 8 +4);"Shortcut K=set";
924 PROCrect(SCBOXX%, SCBOXY%-2,16*9,39,7)
930 ENDPROC

940 DEF PROCprintBitmapHelp(x%,y%)
945 PROCshort(x%,y%  ,"","<>"," Select bitmap")
950 PROCshort(x%,y%+1,""," R"," Num frames")
955 PROCshort(x%,y%+2,""," O"," Loop type") 
960 PROCshort(x%,y%+3,""," I"," Loop speed")
970 ENDPROC

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
1465 IF BSstate%>0 THEN ENDPROC
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
1572 COLOUR 9 : PRINT TAB(x%+7,y%);~FNindTOrgb(clu%,0);
1575 COLOUR 10: PRINT TAB(x%+9,y%);"00";
1577 COLOUR 10: PRINT TAB(x%+9,y%);~FNindTOrgb(clu%,1);
1580 COLOUR 12: PRINT TAB(x%+11,y%);"00";
1582 COLOUR 12: PRINT TAB(x%+11,y%);~FNindTOrgb(clu%,2);
1585 COLOUR 15
1590 ENDPROC

1599 REM ------ Grid/Bitmap Update Functions

1650 DEF PROCsetCol(x%,y%,c%)
1655 REM set colour in screen grid AND Data Grid G%
1660 ind%=x%+y%*W%: U%(ind%)=G%(ind%, BM%) 
1665 G%(ind%, BM%)=c%
1670 PROCfilledRect(1+GRIDX%+x%*8, 1+GRIDY%+y%*8, 6, 6, c%)
1680 PROCupdateBitmapPixel(BM%, x%, y%, c%)
1690 ENDPROC

1700 DEF PROCclearGrid(col%, bmap%)
1701 REM clear grid to a colour (Screen and Data Grids)
1702 REM update of bitmap must be done separately
1710 LOCAL i%
1720 FOR i%=0 TO W%*H%-1
1730 U%(i%) = G%(i%, bmap%) : G%(i%, bmap%)=col%
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
1910 LOCAL clu%
1920 VDU 23,27,0,bmap%   : REM Select bitmap n
1925 VDU 23,0,&A0,bmap%+&FA00;5,&C2,0;W%*H%*4;
1930 FOR I%=0 TO W%*H%-1
1935 clu%=CL%(G%(I%, bmap%))     : REM lookup RGB index
1940 VDU FNindTOrgb(clu%,0), FNindTOrgb(clu%,1), FNindTOrgb(clu%,2), 255
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
2050 VDU FNindTOrgb(clu%,0), FNindTOrgb(clu%,1), FNindTOrgb(clu%,2), 255
2060 PROCupdateSpriteBitmap(bmap%)
2090 ENDPROC

2099 REM ------ Sprite Functions

2100 DEF PROCcreateSprite(w%,h%)
2102 REM setup the sprite and bitmap. Clear both grids
2105 LOCAL B%
2110 FOR B%=0 TO NumBitmaps%-1
2115 VDU 23,27,0,B%       : REM Select bitmap
2120 VDU 23,27,2,w%;h%;0;0; : REM create empty bitmap
2125 NEXT B%
2130 VDU 23,27,4,0        : REM Select sprite 0
2135 VDU 23,27,5          : REM Clear frames
2140 FOR B%=0 TO NumBitmaps%-1
2145 VDU 23,27,6,B%       : REM Add bitmap n as a frame of sprite
2150 NEXT B%
2160 VDU 23,27,11         : REM Show
2165 VDU 23,27,7,1        : REM activate
2170 VDU 23,27,13,SPX%; SPY%; : REM display
2190 ENDPROC

2200 DEF PROCupdateSpriteBitmap(bmap%)
2205 REM display bitmap and update sprite with bitmap
2210 VDU 23,27,0,bmap%
2220 VDU 23,27,3,BMX%(bmap%);BMY%(bmap%); : REM draw bitmap
2230 VDU 23,27,15: REM Refresh the sprites
2240 ENDPROC

2250 DEF PROCtoggleLoopType
2252 REM loop type : 0=left to right loop, 1=ping-pong
2254 LoopType%=1-LoopType% : LoopDir%=1 : SF%=0
2256 COLOUR 54 : PRINT TAB(36,12);CHR$(240+LoopType%)
2260 ENDPROC

2270 DEF PROCsetLoopSpeed
2275 LS=FNinputInt("Loop Speed (1-99)")
2280 IF LS>0 AND LS<100 THEN SpriteDelay%=LS
2290 ENDPROC

2300 DEF PROCshowSprite
2305 REM show sprite animation
2310 Ctr% = Ctr% - 1
2320 IF Ctr%=0 THEN SF%=SF%+LoopDir% 
2322 IF Ctr%=0 AND LoopType%=0 AND SF%=NSF% THEN SF%=0
2324 IF Ctr%=0 AND LoopType%=1 AND (SF%=NSF%-1 OR SF%=0) THEN LoopDir%=LoopDir% * -1
2328 IF Ctr%=0 THEN Ctr%=SpriteDelay% 
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

2599 REM ------ undo

2600 DEF PROCcopyToUndo(b%)
2610 LOCAL i%
2620 FOR i%=0 TO W%*H%-1 : U%(i%) = G%(i%, b%) : NEXT i%
2630 ENDPROC

2700 DEF PROCdoUndo(b%)
2710 LOCAL i%,t%
2715 REM swap undo/grid so using undo again, restores state
2720 FOR i%=0 TO W%*H%-1 : t% = G%(i%,b%): G%(i%,b%) = U%(i%): U%(i%) = t% : NEXT i%
2730 PROCupdateScreenGrid(b%)
2740 PROCupdateBitmapFromGrid(b%)
2790 ENDPROC


2999 REM ------ File Handling

3000 DEF PROCshowFilename(fn$)
3005 REM just display filename in status bar
3010 GCOL 0,15 : MOVE 0,FLINE%*8-4 : DRAW 320,FLINE%*8-4
3020 PRINT TAB(0,FLINE%);SPC(40);
3030 COLOUR 31 : PRINT TAB(0,FLINE%);"FILE:";TAB(6,FLINE%);fn$;
3090 ENDPROC

3100 DEF PROCloadSaveFile(SV%)
3110 fmt% = FNinputInt("Format 1)RGB8 2)RGBA8 3)RGBA2")
3120 IF fmt%<1 OR fmt%>3 THEN ENDPROC
3130 yn$ = FNinputStr("Multiple Frames (y/N)")
3140 IF yn$ = "y" OR yn$ = "Y" THEN PROCmultiple(SV%, fmt%) : ENDPROC
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
3260 F$ = Prefix$ + STR$(N%+1) + FEXT$(fmt%)
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
3405 PROCcopyToUndo(b%)
3410 IF alpha%=1 THEN datw%=4 ELSE datw%=3
3415 FOR I%=0 TO (W%*H%)-1
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
3405 PROCcopyToUndo(b%)
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
3715 IF h%=0 THEN PRINT TAB(20,FLINE%);"Failed to open file"; : ENDPROC
3720 FOR I%=0 TO (W%*H%)-1
3730 RGBIndex% = CL%(G%(I%, b%)) : REM lookup the RGB colour index for this colour 
3740 BPUT#h%, FNindTOrgb(RGBIndex%,0)
3742 BPUT#h%, FNindTOrgb(RGBIndex%,1)
3744 BPUT#h%, FNindTOrgb(RGBIndex%,2)
3746 IF alpha%=1 THEN  BPUT#h%, &FF
3750 NEXT
3760 CLOSE#h%
3790 ENDPROC

3800 DEF PROCsaveDataFile2bit(f$, b%)
3801 REM save raw data to a file. RGBA2222 format with no header.
3805 LOCAL I%, RGBIndex%, h%
3810 h% = OPENOUT(f$)
3815 IF h%=0 THEN PRINT TAB(20,FLINE%);"Failed to open file"; : ENDPROC
3820 FOR I%=0 TO (W%*H%)-1
3830 RGBIndex% = CL%(G%(I%, b%)) : REM lookup the RGB colour index for this colour 
3840 out% = &C0 OR RGBIndex%
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
3932 IF h%=0 THEN PRINT TAB(20,FLINE%);"Failed to open file"; : ENDPROC
3935 FOR I%=0 TO (W%*H%)-1
3940 IF I% MOD PPL% = 0 THEN PROCprintFileLine(h%,SS$) : SS$=STR$(ln%)+" DATA " : ln%=ln%+10
3945 RGBIndex% = CL%(G%(I%, b%)) : REM lookup the RGB colour index for this colour 
3950 FOR J%=0 TO 2
3955 IF FNindTOrgb(RGBIndex%,J%)=0 THEN SS$ = SS$+"0" ELSE SS$ = SS$+"&"+STR$~(FNindTOrgb(RGBIndex%,J%))
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
4032 IF h%=0 THEN PRINT TAB(20,FLINE%);"Failed to open file"; : ENDPROC
4035 FOR I%=0 TO (W%*H%)-1
4040 IF I% MOD PPL% = 0 THEN PROCprintFileLine(h%,SS$) : SS$=STR$(ln%)+" DATA " : ln%=ln%+10
4045 RGBIndex% = CL%(G%(I%, b%)) : REM lookup the RGB colour index for this colour 
4050 PIX%=0
4060 IF RGBIndex%>0 THEN PIX%=PIX% OR &C0 : REM alpha=1
4065 IF PIX%=0 THEN SS$=SS$+"0" ELSE SS$=SS$+"&"+STR$~(PIX%)
4070 IF I% MOD PPL% < (PPL%-1) THEN SS$=SS$+","
4075 NEXT I%
4080 PROCprintFileLine(h%, SS$)
4085 CLOSE#h%
4090 ENDPROC

4100 DEF PROCexport
4105 LOCAL frames% : frames%=1
4110 fmt% = FNinputInt("Format 1)RGB8 2)RGBA8 3)RGBA2")
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

5000 REM ------- Generic Functions

5010 DEF PROCfilledRect(x%,y%,w%,h%,c%)
5005 REM PROCfilledRect draw a filled rectangle. assume screen scaling OFF
5020 GCOL 0,c%
5030 MOVE x%,y% 
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
5305 VDU 23,0,192,0,23,1,0 
5310 PROCreadConfigFile(conf_file$)
5320 REPEAT
5322 ret%=FNdoconfig(conf_file$)
5324 CLS
5326 UNTIL ret%=1
5330 IF CONFIG_SIZE=2 THEN W%=8:H%=8 ELSE W%=16:H%=16
5335 ENDPROC

5340 DEF FNdoconfig(conf_file$)
5342 LOCAL in_str$, in_int%, l%
5344 PROCprintTitle : l%=4
5346 l%=FNprintConfig(l%) : l%=l%+1
5350 PRINT TAB(0,l%); :C. 15: PRINT "C"; : C. C1: PRINT" to configure, ";
5355 C. 15:PRINT "RETURN";:C. C1:PRINT" to continue.";:C. 15: INPUT in_str$
5360 IF in_str$<>"c" AND in_str$<>"C" THEN =1
5365 l%=l%+2 : in_int%=FNinputOpts2(l%,"Sprite Size",1,"16x16","8x8") 
5370 IF in_int%=2 THEN CONFIG_SIZE=2 ELSE CONFIG_SIZE=1
5375 l%=l%+1 : in_int%=FNinputOpts2(l%,"Joystick",2,"Yes","No") 
5380 IF in_int%=1 THEN CONFIG_JOY=1 ELSE CONFIG_JOY=0
5385 l%=l%+2 : in_int%=FNinputOpts2(l%, "Type",1,"Bitmaps","Sprite sheet") 
5390 IF in_int%=2 THEN CONFIG_TYPE=2 ELSE CONFIG_TYPE=1
5395 =0

5400 DEF FNprintConfig(line%)
5410 C. C1: PRINT TAB(0,line%);"Sprite Size  : "; : C. C2
5420 IF CONFIG_SIZE=2 THEN PRINT "8x8" ELSE PRINT "16x16"
5425 line%=line%+1
5430 C. C1: PRINT TAB(0,line%);"Joystick     : "; : C. C2
5440 IF CONFIG_JOY=1 THEN PRINT "Enabled" ELSE PRINT "Disabled"
5445 line%=line%+1
5450 IF CONFIG_JOY=1 THEN C. C1 : PRINT "Joy Delay    : ";:C. C2 : PRINT ;CONFIG_JOYDELAY;: line%=line%+1
5460 C. C1: PRINT TAB(0,line%);"Editing type : "; : C. C2
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
5625 IF var$="SIZE" THEN CONFIG_SIZE=VAL(val$)
5630 IF var$="TYPE" THEN CONFIG_TYPE=VAL(val$)
5635 IF var$="JOYDELAY" THEN CONFIG_JOYDELAY=VAL(val$)
5640 IF var$="FEXT1" THEN FEXT$(1)=val$
5642 IF var$="FEXT2" THEN FEXT$(3)=val$
5644 IF var$="FEXT3" THEN FEXT$(3)=val$
5646 IF var$="C1" THEN C1=VAL(val$)
5648 IF var$="C2" THEN C2=VAL(val$)
5690 ENDPROC

5700 DEF FNinputOpts2(line%,base$,hili%,opt1$,opt2$)
5710 C. C1: PRINT TAB(0,line%);base$;" ";
5720 IF hili%=1 THEN COLOUR 15
5725 PRINT "1) ";opt1$;" ";
5727 C. C1
5730 IF hili%=2 THEN COLOUR 15
5735 PRINT "2) ";opt2$;" ";
5780 COLOUR 15 : INPUT in%
5790 =in% 

5800 DEF PROCsetupChars
5810 VDU 23,240,0,&20,&40,&FF,&40,&20,0,0 : REM left arrow
5812 VDU 23,241,0,&24,&42,&FF,&42,&24,0,0 : REM bidirectional
5814 VDU 23,242,0,&04,&02,&FF,&02,&04,0,0 : REM right 
5816 VDU 23,243,&10,&38,&54,&10,&10,&10,&10,0 : REM up 
5818 VDU 23,244,&10,&10,&10,&10,&54,&38,&10,0 : REM down 
5830 ENDPROC

5899 REM -------  block functions 
5900 DEF PROCmarkBlock
5910 IF BSstate%=0 THEN BSstate%=1 : HaveBlock%=0
5920 IF BSstate%=1 THEN BSrect%(0)=PX% : BSrect%(1)=PY% : BSrect%(2)=PX% : BSrect%(3)=PY%
5930 IF BSstate%=2 THEN BSrect%(2)=PX% : BSrect%(3)=PY%
5960 BSstate% = BSstate%+1 : IF BSstate%=3 THEN BSstate%=0
5995 ENDPROC

6000 DEF PROCdoBlockFill(c%,b%)
6005 PROCcopyToUndo(b%)
6010 FOR y%=BSrect%(1) TO BSrect%(3)
6020 FOR x%=BSrect%(0) TO BSrect%(2)
6030 G%(x%+W%*y%, b%)=c%
6035 PROCfilledRect(1+GRIDX%+x%*8, 1+GRIDY%+y%*8, 6, 6, c%)
6040 NEXT x% : NEXT y%
6050 PROCupdateBitmapFromGrid(b%)
6095 ENDPROC

6100 DEF PROCblockCursor(switch%)
6105 LOCAL col%, xdiff%, ydiff%, x0%,y0%,x1%,y1%
6107 IF BSstate%=0 THEN ENDPROC
6110 BSrect%(2)=PX% : BSrect%(3)=PY% : REM new curs pos
6115 x0%=BSrect%(0) : y0%=BSrect%(1) : x1%=BSrect%(2) : y1%=BSrect%(3)
6120 IF BSrect%(0) > BSrect%(2) THEN BSstate%=0 : PROCgridCursor(1) :ENDPROC
6125 IF BSrect%(1) > BSrect%(3) THEN BSstate%=0 : PROCgridCursor(1) :ENDPROC
6130 xdiff% = x1%-x0% 
6135 ydiff% = y1%-y0%
6140 IF switch%=0 THEN col%=GRIDCOL% ELSE col%=COL%
6150 PROCrect(GRIDX%+x0%*8, GRIDY%+y0%*8, 8*(xdiff%+1), 8*(ydiff%+1), col%)
6160 ENDPROC

6200 DEF PROCblockFill(c%,b%)
6210 IF BSstate%=0 THEN ENDPROC
6220 IF BSstate%=2 THEN BSrect%(2)=PX% : BSrect%(3)=PY%
6230 IF BSstate%=2 THEN PROCdoBlockFill(c%,b%) : PROCblockCursor(0)
6240 BSstate%=0
6260 ENDPROC

6300 DEF PROCcopyBlock(b%)
6305 LOCAL x%,y%,xx%,yy%
6310 IF BSstate%=0 THEN ENDPROC
6315 IF BSstate%=2 THEN BSrect%(2)=PX% : BSrect%(3)=PY%
6320 FOR y%=BSrect%(1) TO BSrect%(3)
6330 FOR x%=BSrect%(0) TO BSrect%(2)
6340 xx%=x%-BSrect%(0) : yy%=y%-BSrect%(1)
6350 BLOCK%(xx%+W%*yy%)=G%(x%+W%*y%, b%)
6360 NEXT x% : NEXT y%
6370 BlockW%=BSrect%(2)-BSrect%(0)+1
6375 BlockH%=BSrect%(3)-BSrect%(1)+1
6380 HaveBlock%=1 : BSstate%=0
6390 ENDPROC

6400 DEF PROCcopyImage(b%)
6405 LOCAL i%
6420 FOR i%=0 TO W%*H%-1 : BLOCK%(i%)=G%(i%, b%) : NEXT i%
6430 BlockW%=W% : BlockH%=H%
6440 HaveBlock%=1 : BSstate%=0
6490 ENDPROC

6500 DEF PROCpasteBlock(b%)
6502 PROCcopyToUndo(b%)
6505 LOCAL x%,y%,xx%,yy%
6510 IF HaveBlock%=0 THEN ENDPROC
6520 FOR y%=0 TO BlockH%-1
6530 FOR x%=0 TO BlockW%-1
6540 xx%=x%+PX% : yy%=y%+PY%
6550 IF xx%<W% AND yy%<H% THEN G%(xx%+W%*yy%, b%)=BLOCK%(x%+W%*y%)
6555 IF xx%<W% AND yy%<H% THEN PROCfilledRect(1+GRIDX%+xx%*8, 1+GRIDY%+yy%*8, 6, 6, BLOCK%(x%+y%*H%))
6560 NEXT x% : NEXT y%
6570 PROCupdateBitmapFromGrid(b%)
6590 ENDPROC

6600 DEF PROCmirrorSelected(x1%,y1%,x2%,y2%,b%)
6601 REM flips left-right
6605 LOCAL x%,y%,t%,bw%,ic%,io%
6610 PROCcopyToUndo(b%)
6615 bw%=x2%-x1%+1
6620 FOR y%=y1% TO y2%
6630 FOR x%=x1% TO x1%+(bw% DIV 2)-1
6635 ic%=x%+W%*y% : REM current
6640 io%=(x2%-x%+x1%)+W%*y% : REM opposite
6650 t%=G%(ic%,b%) : G%(ic%,b%)=G%(io%,b%) : G%(io%,b%)=t% : REM SWAP
6660 NEXT x% : NEXT y%
6670 REM BSstate%=0
6680 PROCupdateBitmapFromGrid(b%) : PROCupdateScreenGrid(b%)
6690 ENDPROC

6700 DEF PROCflipSelected(x1%,y1%,x2%,y2%,b%)
6701 REM flips up-down
6705 LOCAL x%,y%,t%,bw%,ic%,io%
6710 PROCcopyToUndo(b%)
6715 bh%=y2%-y1%+1
6720 FOR x%=x1% TO x2%
6730 FOR y%=y1% TO y1%+(bh% DIV 2)-1
6735 ic%=x%+W%*y% : REM current
6740 io%=x%+W%*(y2%-y%+y1%) : REM opposite
6750 t%=G%(ic%,b%) : G%(ic%,b%)=G%(io%,b%) : G%(io%,b%)=t% : REM SWAP
6760 NEXT y% : NEXT x%
6770 REM BSstate%=0
6780 PROCupdateBitmapFromGrid(b%) : PROCupdateScreenGrid(b%)
6790 ENDPROC

6800 DEF PROCrotateSelected(d%,x1%,y1%,x2%,y2%,b%)
6801 REM rotate
6805 LOCAL x%,y%,bw%,bh%,i%, ic%,ir%
6810 PROCcopyToUndo(b%)
6812 FOR i%=0 TO W%*H%-1 : R%(i%)=G%(i%, b%) : NEXT i%
6815 bw%=x2%-x1%+1 : bh%=y2%-y1%+1
6820 IF bw% <> bh% THEN C.1:PRINT TAB(30,FLINE%);"not square"; : ENDPROC
6825 FOR y%=y1% TO y2%
6830 FOR x%=x1% TO x2%
6835 ic%=x%+y%*W%
6840 IF d%=0 THEN ir%=(x2%-(y%-y1%)) + (y1%+(x%-x1%))*W%: REM ccw
6845 IF d%=1 THEN ir%=(x1%+(y%-y1%)) + (y2%-(x%-x1%))*W%: REM cw
6850 R%(ir%)=G%(ic%, b%)
6855 NEXT x% : NEXT y%
6860 FOR i%=0 TO W%*H%-1 : G%(i%, b%)=R%(i%) : NEXT i%
6870 REM BSstate%=0
6880 PROCupdateBitmapFromGrid(b%) : PROCupdateScreenGrid(b%)
6890 ENDPROC

6999 REM -------  Flood fill 

7000 DEF PROCfloodFill(x%,y%,c%,b%)
7005 LOCAL i%, ii%, bcal%
7010 PROCcopyToUndo(b%)
7015 i%=x%+W%*y%
7020 bcol%=G%(i%,b%) : REM background colour to fill
7030 FFlen%=1 : FF%(FFlen%-1)=i%
7040 REPEAT 
7050 ii%=FNnextItemFF
7060 IF ii% > -1 THEN PROCdoFloodFill(ii%,bcol%,c%,b%)
7070 UNTIL FFlen%=0
7080 PROCupdateBitmapFromGrid(b%) : REM PROCupdateScreenGrid(b%)
7090 ENDPROC

7100 DEF FNnextItemFF
7110 IF FFlen%=0 THEN =-1
7120 FFlen%=FFlen%-1 
7130 =FF%(FFlen%)

7140 DEF FNaddItemFF(item%)
7150 IF FFlen%=FFlenMAX% THEN =-1
7160 FF%(FFlen%)=item% : FFlen%=FFlen%+1 
7170 =FFlen%

7200 DEF PROCdoFloodFill(i%,bcol%,c%,b%)
7202 LOCAL xx%,yy%,ret%
7204 xx%=i% MOD W% : yy%=i% DIV W%
7210 G%(i%,b%)=c% : PROCfilledRect(1+GRIDX%+xx%*8, 1+GRIDY%+yy%*8, 6, 6, c%)
7220 IF xx%>0 THEN IF G%(i%-1,b%)=bcol% THEN ret%=FNaddItemFF(i%-1) : REM left
7225 IF ret%=-1 THEN STOP
7230 IF xx%<(W%-1) THEN IF G%(i%+1,b%)=bcol% THEN ret%=FNaddItemFF(i%+1)  : REM right
7235 IF ret%=-1 THEN STOP
7240 IF yy%>0 THEN IF G%(i%-W%,b%)=bcol% THEN ret%=FNaddItemFF(i%-W%) : REM up
7245 IF ret%=-1 THEN STOP
7250 IF yy%<(H%-1) THEN IF G%(i%+W%,b%)=bcol% THEN ret%=FNaddItemFF(i%+W%) : REM down
7255 IF ret%=-1 THEN STOP
7290 ENDPROC


8000 REM ------- Colour lookup Functions ------------
8005 :

8010 DEF PROCloadLUT
8011 REM Load the RGB Look up table
8012 REM CL%() is BBC Col to RGBIndex
8013 REM RGB%() is a packed array of the RGB colours
8014 REM REVLU%() is a reverse lookup table to get the colour  
8020 LOCAL I%
8025 RESTORE 8210
8030 FOR I%=0 TO 63 
8040 READ CL%(I%)
8050 NEXT
8060 FOR I%=0 TO 63
8070 READ REVLU%(I%)
8080 NEXT
8090 ENDPROC

8100 DEF FNbbcTOrgb(bbccol%,comp%) : REM convert a bbccol to RGB component-wise
8110 =FNindTOrgb(CL%(bbccol%))

8120 DEF FNindTOrgb(ind%,comp%) : REM convert rgb index to RGB comp. 0=R,1=G,2=B
8130 IF comp%=0 THEN tb%=(ind% AND &30) DIV 16
8135 IF comp%=1 THEN tb%=(ind% AND &0C) DIV 4 
8140 IF comp%=2 THEN tb%=ind% AND &03
8150 =TTE%(tb%)

8200 REM Colour mapping to RGB 
8210 DATA &00, &20, &08, &28, &02, &22, &0A, &2A
8220 DATA &15, &30, &0C, &3C, &03, &33, &0F, &3F
8230 DATA &01, &04, &05, &06, &07, &09, &0B, &0D
8240 DATA &0E, &10, &11, &12, &13, &14, &16, &17
8250 DATA &18, &19, &1A, &1B, &1C, &1D, &1E, &1F
8260 DATA &21, &23, &24, &25, &26, &27, &29, &2B
8270 DATA &2C, &2D, &2E, &2F, &31, &32, &34, &35
8280 DATA &36, &37, &38, &39, &3A, &3B, &3D, &3E
8300 REM - RGB colours with a reverse map
8310 DATA  0, 16,  4, 12, 17, 18, 19, 20,  2, 21,  6, 22, 10, 23, 24, 14
8320 DATA 25, 26, 27, 28, 29,  8, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39
8330 DATA  1, 40,  5, 41, 42, 43, 44, 45,  3, 46,  7, 47, 48, 49, 50, 51
8340 DATA  9, 52, 53, 13, 54, 55, 56, 57, 58, 59, 60, 61, 11, 62, 63, 15

8500 DEF PROCloadBitshiftTable
8501 REM lookup table for BitShift for RGBA2222 (don't have nice bit-shift operators)
8505 LOCAL col%,comp%
8510 RESTORE 8610
8520 FOR comp%=0 TO 3 : FOR col%=0 TO 3
8530 READ BSTAB%(col%,comp%) 
8540 NEXT col% : NEXT comp%
8545 REM Two-bit TO Eight-bit convert
8550 FOR comp%=0 TO 3
8560 READ TTE%(comp%)
8570 NEXT comp%
8595 ENDPROC

8600 REM bitshift lookup 
8610 DATA 0,1,2,3, 0,4,8,&0C, 0,&10,&20,&30, 0,&40,&80,&C0
8620 DATA 0,&55,&AA,&FF

10000 REM  ------------ Error Handling -------------
10010 VDU 23, 0, 192, 1 : REM turn on normal logical screen scaling
10020 VDU 23, 1, 1 : REM enable text cursor
10025 @%=&90A
10030 COLOUR 15
10040 IF ISEXIT=0 PRINT:REPORT:PRINT " @ line ";ERL:END
10050 PRINT : PRINT "Goodbye"

