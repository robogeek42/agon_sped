  10 MODE 8
  20 DIM graphics 1024 : REM memory for file load 
  30 MB%=&40000 : REM user memory base
  40 DIM CLU% 4 : !CLU%=&FFAA5500

 120 PRINT TAB(0,2);"Load Bitmap from RGB 888 data"
 130 PROCloadBitmapRGB888data(0,16,16,10000)
 140 PROCdrawBitmap(0, 20, 0)

 150 PRINT TAB(0,3);"Load Bitmap from RGBA 8888 data"
 160 PROCloadBitmapRGBA8888data(1,16,16,11000)
 170 PROCdrawBitmap(1, 40, 0)

 180 PRINT TAB(0,4);"Load Bitmap from RGBA 2222 data"
 190 PROCloadBitmapRGBA2222data(2,16,16,12000)
 200 PROCdrawBitmap(2, 60, 0)

 220 STOP

 300 DEF PROCdrawBitmap(bm%, x%, y%)
 310 VDU 23,27,0,bm% : REM select bitmap
 320 VDU 23,27,3,x%; y%; : REM display bitmap
 330 ENDPROC

 400 DEF PROCloadBitmapRGB888data(bm%, w%, h%, dat%)
 401 REM Load bitmap num bm% from DATA below at line dat%
 410 RESTORE dat%
 420 VDU 23,27,0,bm% : REM select bitmap
 430 VDU 23,27,1,w%;h%;0;0; : REM create bitmap (data bytes follow)
 440 FOR I%=0 TO (w%*h%)-1
 450 READ datR%, datG%, datB%
 460 VDU datR%, datG%, datB%, &FF
 470 NEXT
 480 ENDPROC

 500 DEF PROCloadBitmapRGBA8888data(bm%, w%, h%, dat%)
 501 REM Load bitmap num bm% from DATA below at line dat%
 510 RESTORE dat%
 520 VDU 23,27,0,bm% : REM select bitmap
 530 VDU 23,27,1,w%;h%;0;0; : REM create bitmap (data bytes follow)
 540 FOR I%=0 TO (w%*h%)-1
 550 READ datR%, datG%, datB%, datA%
 560 VDU datR%, datG%, datB%, datA%
 570 NEXT
 580 ENDPROC

 600 DEF PROCloadBitmapRGBA2222data(bm%, w%, h%, dat%)
 601 REM Load bitmap num bm% from DATA below at line dat%
 610 RESTORE dat%
 620 VDU 23,27,0,bm% : REM select bitmap
 630 VDU 23,27,1,w%;h%;0;0; : REM create bitmap (data bytes follow)
 640 FOR I%=0 TO (w%*h%)-1
 650 READ dat%
 660 datR%=(dat% AND &03)
 670 datG%=(dat% AND &0C) DIV 4
 680 datB%=(dat% AND &30) DIV 16
 690 VDU ?(CLU%+datR%), ?(CLU%+datG%), ?(CLU%+datB%), &FF
 700 NEXT
 710 ENDPROC


10000 REM a_rgb888.txt 3 bytes per pixel, RGB
10010 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
10020 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
10030 DATA 0,0,0,0,&55,0,0,&AA,&55,&55,&FF,&AA,0,0,0,0,0,0,0,0,0,0,0,0
10040 DATA 0,0,0,0,0,0,0,0,0,&55,&FF,&AA,&55,&FF,&AA,&55,&FF,&AA,0,0,0,0,0,0
10050 DATA 0,0,0,0,0,0,0,&55,0,0,&AA,&55,&55,&FF,&AA,0,0,0,0,0,0,0,0,0
10060 DATA 0,0,0,0,0,0,0,&AA,&55,0,&AA,&55,&55,&FF,&AA,0,0,0,0,0,0,0,0,0
10070 DATA 0,0,0,0,0,0,0,0,0,0,&55,0,0,&AA,&55,&55,&FF,&AA,0,0,0,0,0,0
10080 DATA 0,0,0,0,&AA,&55,0,&AA,&55,&55,&FF,&AA,0,0,0,0,0,0,0,0,0,0,0,0
10090 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,&55,0,0,&AA,&55,0,&AA,&55,0,&AA,&55
10100 DATA 0,&AA,&55,0,&AA,&55,&55,&FF,&AA,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
10110 DATA 0,0,0,0,0,0,0,0,0,0,&55,0,0,&AA,&55,0,&AA,&55,0,&AA,&55,0,&AA,&55
10120 DATA 0,&AA,&55,0,&AA,&55,0,&AA,&55,&55,&FF,&AA,0,0,0,0,0,0,0,0,0,0,0,0
10130 DATA 0,0,0,0,0,0,0,&55,0,0,&AA,&55,0,&AA,&55,0,&AA,&55,0,&AA,&55,0,&AA,&55
10140 DATA 0,&AA,&55,0,&AA,&55,0,&AA,&55,0,&AA,&55,&55,&FF,&AA,0,0,0,0,0,0,0,0,0
10150 DATA 0,0,0,0,&55,0,0,&AA,&55,&AA,0,0,&AA,0,0,&AA,0,0,0,&AA,&55,0,&AA,&55
10160 DATA 0,&AA,&55,&AA,0,0,&AA,0,0,&AA,0,0,0,&AA,&55,&55,&FF,&AA,0,0,0,0,0,0
10170 DATA 0,0,0,0,&55,0,0,&AA,&55,&AA,0,0,&FF,&FF,0,&AA,0,0,0,&AA,&55,0,&FF,&55
10180 DATA 0,&AA,&55,&AA,0,0,&FF,&FF,0,&AA,0,0,0,&AA,&55,&55,&FF,&AA,0,0,0,0,0,0
10190 DATA 0,0,0,0,&55,0,0,&AA,&55,0,&AA,&55,&AA,0,0,&AA,0,0,0,&AA,&55,0,&FF,&55
10200 DATA 0,&AA,&55,&AA,0,0,&AA,0,0,0,&AA,&55,0,&AA,&55,0,&AA,&55,0,0,0,0,0,0
10210 DATA 0,0,0,0,0,0,0,&55,0,0,&AA,&55,0,&AA,&55,0,&AA,&55,0,&FF,&55,0,&FF,&55
10220 DATA 0,&FF,&55,0,&AA,&55,0,&AA,&55,0,&AA,&55,0,&AA,&55,0,0,0,0,0,0,0,0,0
10230 DATA 0,0,0,0,0,0,0,0,0,0,&55,0,0,&AA,&55,0,&AA,&55,0,&55,0,0,&55,0
10240 DATA 0,&55,0,0,&AA,&55,0,&AA,&55,0,&AA,&55,0,0,0,0,0,0,0,0,0,0,0,0
10250 DATA 0,0,0,0,0,0,0,0,0,0,&55,0,0,&AA,&55,0,&55,&55,0,&55,&55,0,&55,&55
10260 DATA 0,&55,&55,0,&55,&55,0,&AA,&55,0,&AA,&55,0,0,0,0,0,0,0,0,0,0,0,0
10270 DATA 0,0,0,0,0,0,0,0,0,0,&55,0,0,&AA,&55,0,&AA,&55,0,&AA,&55,0,&AA,&55
10280 DATA 0,&AA,&55,0,&AA,&55,0,&AA,&55,0,&AA,&55,0,0,0,0,0,0,0,0,0,0,0,0
10290 DATA 0,0,0,0,0,0,0,&55,0,0,&AA,&55,0,0,0,0,0,0,0,0,0,0,0,0
10300 DATA 0,0,0,0,0,0,0,0,0,0,&AA,&55,0,&AA,&55,0,0,0,0,0,0,0,0,0
10310 DATA 0,0,0,0,&55,0,0,&AA,&55,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
10320 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,&AA,&55,0,&AA,&55,0,0,0,0,0,0


11000 REM a_rgba8888.txt 4 bytes per pixel, RGBA
11010 DATA 0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF
11020 DATA 0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF
11030 DATA 0,0,0,&FF,0,&55,0,&FF,0,&AA,&55,&FF,&55,&FF,&AA,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF
11040 DATA 0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,&55,&FF,&AA,&FF,&55,&FF,&AA,&FF,&55,&FF,&AA,&FF,0,0,0,&FF,0,0,0,&FF
11050 DATA 0,0,0,&FF,0,0,0,&FF,0,&55,0,&FF,0,&AA,&55,&FF,&55,&FF,&AA,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF
11060 DATA 0,0,0,&FF,0,0,0,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,&55,&FF,&AA,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF
11070 DATA 0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,&55,0,&FF,0,&AA,&55,&FF,&55,&FF,&AA,&FF,0,0,0,&FF,0,0,0,&FF
11080 DATA 0,0,0,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,&55,&FF,&AA,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF
11090 DATA 0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,&55,0,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF
11100 DATA 0,&AA,&55,&FF,0,&AA,&55,&FF,&55,&FF,&AA,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF
11110 DATA 0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,&55,0,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF
11120 DATA 0,&AA,&55,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,&55,&FF,&AA,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF
11130 DATA 0,0,0,&FF,0,0,0,&FF,0,&55,0,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF
11140 DATA 0,&AA,&55,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,&55,&FF,&AA,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF
11150 DATA 0,0,0,&FF,0,&55,0,&FF,0,&AA,&55,&FF,&AA,0,0,&FF,&AA,0,0,&FF,&AA,0,0,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF
11160 DATA 0,&AA,&55,&FF,&AA,0,0,&FF,&AA,0,0,&FF,&AA,0,0,&FF,0,&AA,&55,&FF,&55,&FF,&AA,&FF,0,0,0,&FF,0,0,0,&FF
11170 DATA 0,0,0,&FF,0,&55,0,&FF,0,&AA,&55,&FF,&AA,0,0,&FF,&FF,&FF,0,&FF,&AA,0,0,&FF,0,&AA,&55,&FF,0,&FF,&55,&FF
11180 DATA 0,&AA,&55,&FF,&AA,0,0,&FF,&FF,&FF,0,&FF,&AA,0,0,&FF,0,&AA,&55,&FF,&55,&FF,&AA,&FF,0,0,0,&FF,0,0,0,&FF
11190 DATA 0,0,0,&FF,0,&55,0,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,&AA,0,0,&FF,&AA,0,0,&FF,0,&AA,&55,&FF,0,&FF,&55,&FF
11200 DATA 0,&AA,&55,&FF,&AA,0,0,&FF,&AA,0,0,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,0,0,0,&FF,0,0,0,&FF
11210 DATA 0,0,0,&FF,0,0,0,&FF,0,&55,0,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,0,&FF,&55,&FF,0,&FF,&55,&FF
11220 DATA 0,&FF,&55,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF
11230 DATA 0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,&55,0,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,0,&55,0,&FF,0,&55,0,&FF
11240 DATA 0,&55,0,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF
11250 DATA 0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,&55,0,&FF,0,&AA,&55,&FF,0,&55,&55,&FF,0,&55,&55,&FF,0,&55,&55,&FF
11260 DATA 0,&55,&55,&FF,0,&55,&55,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF
11270 DATA 0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,&55,0,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF
11280 DATA 0,&AA,&55,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF
11290 DATA 0,0,0,&FF,0,0,0,&FF,0,&55,0,&FF,0,&AA,&55,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF
11300 DATA 0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF
11310 DATA 0,0,0,&FF,0,&55,0,&FF,0,&AA,&55,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF
11320 DATA 0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,0,0,&FF,0,&AA,&55,&FF,0,&AA,&55,&FF,0,0,0,&FF,0,0,0,&FF


12000 REM a_rgba2222.txt format RGBA2222
12010 DATA &0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0
12020 DATA &0,&C4,&D8,&ED,&0,&0,&0,&0,&0,&0,&0,&ED,&ED,&ED,&0,&0
12030 DATA &0,&0,&C4,&D8,&ED,&0,&0,&0,&0,&0,&D8,&D8,&ED,&0,&0,&0
12040 DATA &0,&0,&0,&C4,&D8,&ED,&0,&0,&0,&D8,&D8,&ED,&0,&0,&0,&0
12050 DATA &0,&0,&0,&0,&C4,&D8,&D8,&D8,&D8,&D8,&ED,&0,&0,&0,&0,&0
12060 DATA &0,&0,&0,&C4,&D8,&D8,&D8,&D8,&D8,&D8,&D8,&ED,&0,&0,&0,&0
12070 DATA &0,&0,&C4,&D8,&D8,&D8,&D8,&D8,&D8,&D8,&D8,&D8,&ED,&0,&0,&0
12080 DATA &0,&C4,&D8,&C2,&C2,&C2,&D8,&D8,&D8,&C2,&C2,&C2,&D8,&ED,&0,&0
12090 DATA &0,&C4,&D8,&C2,&CF,&C2,&D8,&DC,&D8,&C2,&CF,&C2,&D8,&ED,&0,&0
12100 DATA &0,&C4,&D8,&D8,&C2,&C2,&D8,&DC,&D8,&C2,&C2,&D8,&D8,&D8,&0,&0
12110 DATA &0,&0,&C4,&D8,&D8,&D8,&DC,&DC,&DC,&D8,&D8,&D8,&D8,&0,&0,&0
12120 DATA &0,&0,&0,&C4,&D8,&D8,&C4,&C4,&C4,&D8,&D8,&D8,&0,&0,&0,&0
12130 DATA &0,&0,&0,&C4,&D8,&D4,&D4,&D4,&D4,&D4,&D8,&D8,&0,&0,&0,&0
12140 DATA &0,&0,&0,&C4,&D8,&D8,&D8,&D8,&D8,&D8,&D8,&D8,&0,&0,&0,&0
12150 DATA &0,&0,&C4,&D8,&0,&0,&0,&0,&0,&0,&0,&D8,&D8,&0,&0,&0
12160 DATA &0,&C4,&D8,&0,&0,&0,&0,&0,&0,&0,&0,&0,&D8,&D8,&0,&0
