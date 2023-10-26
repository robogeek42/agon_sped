   10 REM Stars - vertical scroll. Double buffered mode
   20 REM Assif Mirza
   30 MODE 136 : REM 320x240, 40x30, 64 colours - use double buffered screen MODE 128+8
   40 SCRW% = 320 : SCRH% = 240
   50 NUMS%=40
   60 REM Create stars
   70 DIM SPOS%(NUMS%,2)
   80 FOR S% = 0 TO NUMS% 
   90   SPOS%(S%, 0) = RND(SCRW%) - 1
  100   SPOS%(S%, 1) = RND(SCRH%) - 1
  110   SPOS%(S%, 2) = RND(3)
  120 NEXT S%
  130 CLG : VDU 23,0,195 : CLG : REM Clear both surfaces
  140 REM Loop clearing surface, updating stars, drawing and swap surface
  150 REPEAT
  160   CLG
  170   FOR S% = 0 TO NUMS% 
  180     LET SPOS%(S%,1) = SPOS%(S%,1) - SPOS%(S%,2)
  190     IF SPOS%(S%,1) < 0 THEN PROCnewstar(S%)
  200   NEXT
  210   PROCshow
  220   VDU 23,0,195
  230 UNTIL FALSE
  240 REM draw stars as points
  250 DEF PROCshow
  260 FOR S% = 0 TO NUMS% 
  270   PROCsetcols(S%)
  280   PLOT 69, SPOS%(S%, 0)*4, SPOS%(S%, 1)*4
  290 NEXT S%
  300 ENDPROC
  310 REM Set colours to be white in forground going grey to stars in background
  320 DEF PROCsetcols(N%)
  330 IF SPOS%(N%,2) = 1 THEN GCOL 0, 8
  340 IF SPOS%(N%,2) = 2 THEN GCOL 0, 7
  350 IF SPOS%(N%,2) = 3 THEN GCOL 0, 15
  360 ENDPROC
  370 DEF PROCnewstar(NS%)
  380 SPOS%(NS%,1) = SCRH% - 1
  390 SPOS%(NS%,0) = RND(SCRW%) - 1
  400 REM Keep same star type
  410 ENDPROC
