   10 REM Scrolling Stars Demo 
   11 REM https://github.com/breakintoprogram/agon-bbc-basic/blob/main/tests/scroll_1.bas
   15 :
   20 MODE 8
   30 VDU 23,1,0
   40 *FX 19
   50 GCOL 0,RND(16)
   60 PLOT 69,1279,RND(1024)
   70 VDU 23,7,0,1,1
   80 GOTO 40
