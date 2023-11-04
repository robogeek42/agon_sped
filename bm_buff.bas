10 REM bitmap test - try using the buffer api throughout
20 :
30 MODE 8
40 SW%=320 : SH%=200 : REM Screen size
50 BMWidth%=16 : BMHeight%=16 : REM bitmap size
60 BMX%=100 : BMY%=100 : REM bitmap postion
70 REM Create a simple bitmap
80 BMNum%=0 : REM Bitmap no.
90 BuffID% = BMNum% + &FA00
100 VDU 23, 27, &20; BuffID%;               : REM select bitmap using bufferID
110 VDU 23, 27, &21; BMWidth%; BMHeight%; 0 : REM create bitmap from buffer
120 
120 REM Load bitmap
120 VDU 23, 27, 0, BMNum%; : REM Select bitmap
130 REM Single colour bitmap load
140 REM col1=LSW col2=MSW so &GGRR; &AABB; 
150 VDU 23, 27, 2, BMWidth%; BMHeight%; &AA55; &FFAA; : REM load with one colour 

200 REM draw bitmap
220 VDU 23, 27, 3, BMX%; BMY%; : REM draw bitmap
230 VDU 23, 27, 3, BMX%+20; BMY%; : REM draw bitmap again

290 PRINT "BMNum ";BMNum%;" BuffID ";BuffID%
300 REM Modify bitmap
310 VDU 23, 0, &A0, BuffID%; 5, 2, 0; &55

340 REM draw bitmap
350 VDU 23, 27, 3, BMX%; BMY%+20; : REM draw bitmap
360 VDU 23, 27, 3, BMX%+20; BMY%+20; : REM draw bitmap again
