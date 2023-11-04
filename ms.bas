   10 REM Modify a sprite using buffer API
   20 REM MODE 8
   30 SW%=320
   40 SH%=200
   45 REM Create a simple buffer to be used as a bitmap
   50 BitmapNum%=0 : BID%=&FFF0 + BitmapNum% 
   60 BOFF%=0 : REM Buffer offset
   65 COL%=1 : REM colour to set bitmap to 
   70 VDU 23,0, &A0, BID%; 3, 1024; : REM create a buffer length 1024 (=4*16*16)
   80 VDU 23,0, &A0, BID%; 2        : REM clear buffer
   90 VDU 23,0, &A0, BID%; 0, 1024; : REM prepare writing next 1024 bytes to buffer
  100 READ W%,H%
  110 FOR I%=1 TO W%*H%
  120   READ B%
  130   VDU B%,B%,B%,B% : REM and set data
  140 NEXT
  150 VDU 23,27, &20, BID%;   : REM Select bitmap (using a BufferID)
  160 VDU 23,27, &21, 16;16;0 : REM Create a bitmap from the buffer
  170 :
  180 REM Set up a sprite from the buffer
  200 VDU 23,27,   4, 0      : REM Select sprite 0
  230 VDU 23,27, &26, BID%;  : REM Add bitmap 0 as frame 0 of sprite - use buffer API
  240 VDU 23,27,  11         : REM Show the sprite
  250 VDU 23,27,   7, 1      : REM activate all sprites
  260 :
  270 X%=RND(SW% - 16)
  240 Y%=RND(SH% - 16)
  250 XP%=1
  300 YP%=1
  310 :
  340 REM LOOP -----------------------------------------------
  350 REM Move the sprite
  370 VDU 23,27,4,0,23,27,13,X%;Y%;
  380 X%=X%+XP%
  390 Y%=Y%+YP%
  395 REM bounce
  400 IF X%<0 OR X%>(SW%-16) THEN XP%=-XP%
  410 IF Y%<0 OR Y%>(SH%-16) THEN YP%=-YP%

  440 REM Modify the bitmap buffer BID% - set differnt pixels to a colour
  450 VDU 23, 0, &A0, BID%; 5, 2, BOFF%; COL%
  460 BOFF%=BOFF%+1
  470 IF BOFF%=255 THEN BOFF%=0 : COL%=COL%+1

 
  640 *FX 19 : REM wait for vertical sync
  650 VDU 23,27,15: REM Refresh the sprites
  670 REM GOTO 340 : REM LOOP ------------------------------------
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
