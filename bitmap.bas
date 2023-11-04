10 REM bitmap test
20 :
30 MODE 8
40 SW%=320 : SH%=200 : REM Screen size
50 BMWidth%=16 : BMHeight%=16 : REM bitmap size
60 BMX%=100 : BMY%=100 : REM bitmap postion
70 REM Create a simple bitmap
80 BMNum%=0 : REM Bitmap no.
90 BuffID% = BMNum% + &FA00 : REM this should be buffer ID corresponding to this bitmap
100 VDU 23, 27, 0, BMNum%; : REM Select bitmap
107 REM Single colour bitmap load
108 REM col1=LSW col2=MSW so &GGRR; &AABB; 
110 VDU 23, 27, 2, BMWidth%; BMHeight%; &0055; &FFAA; : REM load with one colour 

200 REM draw bitmap
220 VDU 23, 27, 3, BMX%; BMY%; : REM draw bitmap
230 VDU 23, 27, 3, BMX%+20; BMY%; : REM draw bitmap again

290 PRINT "BMNum ";BMNum%;" BuffID ";BuffID%
300 REM Modify bitmap - adjust just one byte to test
305 REM this doesn't work
310 VDU 23, 0, &A0, BuffID%; 5, 2, 0; &FF
320 REM use extended API to modify 4-bytes
325 REM this doesn't work either
330 VDU 23, 0, &A0, BuffID%; 5, &C2, 16; 4; &FFFF; &FFFF; : REM Adjust 4 bytes

340 REM draw bitmap
350 VDU 23, 27, 3, BMX%; BMY%+20; : REM draw bitmap
360 VDU 23, 27, 3, BMX%+20; BMY%+20; : REM draw bitmap again
