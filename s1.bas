   10 REM Sprite test
   20 :
   30 MODE 8
   40 SW%=320
   50 SH%=200
   70 :
   80 REM Create blank bitmap
   85 REM VDU 23,27,1, w; h; R1,G1,B1,A1,R2,G2,B2,A2,....R256,G256,B256,A256
   86 REM 1 = load colour bitmap
   87 REM A=0 is off, A>=1 is full alpha
   90 :
  100 VDU 23,27,0,0: REM Select bitmap 0
  120 VDU 23,27,1,16;16;
  130 FOR I%=1 TO 16*16
  150   VDU 255, 0, 0, 1
  160 NEXT
  170 :
  180 REM Set up a sprite
  190 :
  230 X%=0
  240 Y%=64
  270 VDU 23,27,4,0: REM Select sprite 0
  280 VDU 23,27,5: REM Clear frames for current sprite
  290 VDU 23,27,6,0: REM Add bitmap 0 as frame 0 of sprite
  300 VDU 23,27,11: REM Show the sprite
  320 VDU 23,27,7,1 : REM activate 1 sprite
  330 :
  340 REM Move the sprite
  350 :
  370   VDU 23,27,4,0,23,27,13,X%;Y%;
  430 :
  440 *FX 19
  450 VDU 23,27,15: REM Refresh the sprites
  460 GOTO 370
