   10 REM Sprite Demo
   20 :
   30 MODE 8
   40 SW%=320
   50 SH%=200
   60 C%=1 : REM Number of sprites
   70 PX%=0 : PY%=0
   80 REM Create a simple bitmap
   85 REM sprite interface allocates 8-bit numbered bitmap
   86 REM that correspond to buffers &FA00 - &FAFF
   90 BitmapNum%=0 : BID%=&FA00 + BitmapNum% 
   95 BOFF%=0 : REM Buffer offset
   97 COL%=1 : REM colour to set bitmap to 
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
  330 :
  340 REM LOOP -----------------------------------------------
  350 REM Move the sprite
  360 FOR I%=0 TO C%-1
  370   VDU 23,27,4,I%,23,27,13,X%(I%);Y%(I%);
  380   X%(I%)=X%(I%)+XP%(I%)
  390   Y%(I%)=Y%(I%)+YP%(I%)
  400   IF X%(I%)<0 OR X%(I%)>(SW%-16) THEN XP%(I%)=-XP%(I%)
  410   IF Y%(I%)<0 OR Y%(I%)>(SH%-16) THEN YP%(I%)=-YP%(I%)
  420 NEXT
  430 :

  440 REM Modify the bitmap buffer BID% - set differnt pixels to a colour
  450 VDU 23, 0, &A0, BID%; 5, 2, BOFF%; COL%
  460 BOFF%=BOFF%+1
  470 IF BOFF%=255 THEN BOFF%=0 : COL%=COL%+1

 
  640 *FX 19 : REM wait for vertical sync
  650 VDU 23,27,15: REM Refresh the sprites
  670 GOTO 340 : REM LOOP ------------------------------------
  680 :
  690 STOP

  800 :
  810 REM Bitmap data
  820 :
  830 DATA 16,16
  840 :
  850 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
  860 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
  870 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
  880 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
  890 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
  900 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
  910 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
  920 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
  930 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
  940 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
  950 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
  960 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
  970 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
  980 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
  990 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
  1000 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
