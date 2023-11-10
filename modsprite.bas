   10 REM Sprite Demo
   20 :
   30 MODE 8
   40 SW%=320
   50 SH%=200
   60 C%=4 : REM Number of sprites
   70 PX%=0 : PY%=0
   80 REM Create a simple bitmap
   90 BitmapNum%=0 : BID%=&FA00 + BitmapNum% 
   95 BOFF%=0 : REM Buffer offset
   97 COL%=0 : REM colour to set bitmap to 
   98 NumCols%=3
  100 VDU 23,27,0,BitmapNum%: REM Select bitmap 0 (buffer ID &FA00)
  110 READ W%,H%
  120 VDU 23,27,1,W%;H%; : REM Set w/h of bitmap
  130 FOR I%=1 TO W%*H%
  140   READ B%
  150   VDU B%,B%,B%,B% : REM and set data
  160 NEXT
  170 :
  180 REM Set up some sprites
  190 :
  200 DIM X%(C%-1),Y%(C%-1),XP%(C%-1),YP%(C%-1)
  210 :
  220 FOR I%=0 TO C%-1
  230   X%(I%)=RND(SW% - 16)
  240   Y%(I%)=RND(SH% - 16)
  250   XP%(I%)=1
  260   YP%(I%)=1
  270   VDU 23,27,4,I%: REM Select sprite I%
  280   VDU 23,27,5: REM Clear frames for current sprite
  290   VDU 23,27,6,0: REM Add bitmap 0 as frame 0 of sprite
  300   VDU 23,27,11: REM Show the sprite
  310 NEXT
  320 VDU 23,27,7,C%

  330 DIM C%(3,3)
  335 RESTORE 1110
  340 FOR col=0 TO 2 
  350 READ C%(col,0): READ C%(col,1): READ C%(col,2)
  360 NEXT col

  400 REM LOOP -----------------------------------------------
  410 REM Move the sprite
  420 FOR I%=0 TO C%-1
  430   VDU 23,27,4,I%,23,27,13,X%(I%);Y%(I%);
  440   X%(I%)=X%(I%)+XP%(I%)
  450   Y%(I%)=Y%(I%)+YP%(I%)
  460   IF X%(I%)<0 OR X%(I%)>(SW%-16) THEN XP%(I%)=-XP%(I%)
  470   IF Y%(I%)<0 OR Y%(I%)>(SH%-16) THEN YP%(I%)=-YP%(I%)
  480 NEXT

  500 REM Modify the bitmap buffer BID% - set differnt pixels to a colour
  510 VDU 23, 0, &A0, BID%; 5, &C2, BOFF%*4; 4; 
  515 VDU C%(COL%,0), C%(COL%,1), C%(COL%,2), &FF
  520 BOFF%=BOFF%+1
  530 IF BOFF%=256 THEN BOFF%=0 : COL%=(COL%+1) MOD NumCols%

  600 *FX 19 : REM wait for vertical sync
  610 VDU 23,27,15: REM Refresh the sprites
  620 GOTO 400 : REM LOOP ------------------------------------
  630 :
  690 STOP

  810 REM Bitmap data
  830 DATA 16,16
  850 DATA &FF,&FF,&FF,&FF,&FF,&FF,&FF,&FF,&FF,&FF,&FF,&FF,&FF,&FF,&FF,&FF
  860 DATA &FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,&FF
  870 DATA &FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,&FF
  880 DATA &FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,&FF
  890 DATA &FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,&FF
  900 DATA &FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,&FF
  910 DATA &FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,&FF
  920 DATA &FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,&FF
  930 DATA &FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,&FF
  940 DATA &FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,&FF
  950 DATA &FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,&FF
  960 DATA &FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,&FF
  970 DATA &FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,&FF
  980 DATA &FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,&FF
  990 DATA &FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,&FF
 1000 DATA &FF,&FF,&FF,&FF,&FF,&FF,&FF,&FF,&FF,&FF,&FF,&FF,&FF,&FF,&FF,&FF

 1100 REM Colour data
 1110 DATA &FF,&AA,&55
 1120 DATA &00,&55,&FF
 1130 DATA &55,&FF,&00

