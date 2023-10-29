30 PRINT "load LUT ";
40 DIM CL%(63) : DIM RGB%(64*3) : PROCloadLUT
50 PRINT " done."
60 PRINT "Generate Reverse table"
65 REM FILENAME$="lut_rev.txt"
70 REM HAN%=OPENOUT(FILENAME$)
80 REM DIM OutStr$(120)
85 FOR C%=0 TO 63
90 R% = RGB%(C%*3+0) : RI% = R% DIV 85
95 G% = RGB%(C%*3+1) : GI% = G% DIV 85
100 B% = RGB%(C%*3+2) : BI% = B% DIV 85
110 IND% = RI% * 16 + GI% * 4 + BI%
120 col%=-1
125 FOR I%=0 TO 63
130 IF CL%(I%) = IND% THEN col%=I% : I%=65
140 NEXT I%
150 IF col%=-1 THEN PRINT "error Col ";C%;" ";R%;" ";G%;" ";B%; " Index ";IND% : NEXT C%
160 REM PRINT "Col ";C%;" ";R%;" ";G%;" ";B%; " Col ";col% 
170 REM OutStr$="4000 DATA &";~R%;", &";~G%;", &";~B%;", ";col%
180 PRINT "4000 DATA &";~R%;", &";~G%;", &";~B%;", ";col%
190 REM PRINT#HAN% OutStr$
195 IF C%=32 INPUT A
200 NEXT C%
210 REM CLOSE#HAN%
220 REM PRINT "Done.  Written file ";FILENAME$
999 STOP
4000 REM Colour - RGB Look up
4010 DEF PROCloadLUT
4025 RESTORE
4030 FOR I%=0 TO 63 
4040 READ CL%(I%)
4050 NEXT
4060 FOR I%=0 TO 63
4070 READ RGB%(I%*3),RGB%(I%*3+1),RGB%(I%*3+2)
4080 NEXT
4090 ENDPROC

4200 REM Colour mapping to RGB 
4210 DATA &00, &20, &08, &28, &02, &22, &0A, &2A
4220 DATA &15, &30, &0C, &3C, &03, &33, &0F, &3F
4230 DATA &01, &04, &05, &06, &07, &09, &0B, &0D
4240 DATA &0E, &10, &11, &12, &13, &14, &16, &17
4250 DATA &18, &19, &1A, &1B, &1C, &1D, &1E, &1F
4260 DATA &21, &23, &24, &25, &26, &27, &29, &2B
4270 DATA &2C, &2D, &2E, &2F, &31, &32, &34, &35
4280 DATA &36, &37, &38, &39, &3A, &3B, &3D, &3E
4300 REM - RGB colours 
4310 DATA &00, &00, &00, &00, &00, &55, &00, &00, &AA, &00, &00, &FF
4320 DATA &00, &55, &00, &00, &55, &55, &00, &55, &AA, &00, &55, &FF
4330 DATA &00, &AA, &00, &00, &AA, &55, &00, &AA, &AA, &00, &AA, &FF
4340 DATA &00, &FF, &00, &00, &FF, &55, &00, &FF, &AA, &00, &FF, &FF
4350 DATA &55, &00, &00, &55, &00, &55, &55, &00, &AA, &55, &00, &FF
4360 DATA &55, &55, &00, &55, &55, &55, &55, &55, &AA, &55, &55, &FF
4370 DATA &55, &AA, &00, &55, &AA, &55, &55, &AA, &AA, &55, &AA, &FF
4380 DATA &55, &FF, &00, &55, &FF, &55, &55, &FF, &AA, &55, &FF, &FF
4390 DATA &AA, &00, &00, &AA, &00, &55, &AA, &00, &AA, &AA, &00, &FF
4400 DATA &AA, &55, &00, &AA, &55, &55, &AA, &55, &AA, &AA, &55, &FF
4410 DATA &AA, &AA, &00, &AA, &AA, &55, &AA, &AA, &AA, &AA, &AA, &FF
4420 DATA &AA, &FF, &00, &AA, &FF, &55, &AA, &FF, &AA, &AA, &FF, &FF
4430 DATA &FF, &00, &00, &FF, &00, &55, &FF, &00, &AA, &FF, &00, &FF
4440 DATA &FF, &55, &00, &FF, &55, &55, &FF, &55, &AA, &FF, &55, &FF
4450 DATA &FF, &AA, &00, &FF, &AA, &55, &FF, &AA, &AA, &FF, &AA, &FF
4460 DATA &FF, &FF, &00, &FF, &FF, &55, &FF, &FF, &AA, &FF, &FF, &FF

