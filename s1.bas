   10 REM Sprite test
   20 :
   30 MODE 8
   40 SW%=320 : SH%=200
   50 X%=0 : Y%=64 : Z%=0

   60 REM Set up bitmaps
   70 FOR B%=0 TO 3
   80 VDU 23,27,0,B% : REM Select bitmap 
   90 READ CR%,CG%,CB%
  100 VDU 23,27,2,16;16;CR%,CG%,CB%,&FF : REM create bitmap with single colour
  105 VDU 23,27,3,22*B%;0; : REM draw bitmap
  110 NEXT B%

  120 REM Load sprite
  130 VDU 23,27,4,0: REM Select sprite 0
  140 VDU 23,27,5: REM Clear frames for current sprite
  150 FOR B%=0 TO 3
  160 VDU 23,27,6,B%: REM Add bitmap B% as a frame of sprite
  170 NEXT B%

  180 VDU 23,27,11: REM Show the sprite
  190 VDU 23,27,7,1 : REM activate 1 sprite

  200 REM Move the sprite
  210 VDU 23,27,4,0,23,27,13,X%;Y%;
  220 X%=X%+1 : IF X%>=SW%-16 THEN X%=0
  230 Z%=Z%+1
  240 IF Z%=10 THEN Z%=0 : VDU 23,27,8 : REM next frame
  250 *FX 19
  260 REM VDU 23,27,15: REM Refresh the sprites
  270 GOTO 200

 1000 REM Colour data R G B Y
 1010 DATA &FF,&00,&00
 1020 DATA &00,&FF,&00
 1030 DATA &00,&00,&FF
 1040 DATA &FF,&FF,&00
