   10 FOR M=0 TO 31
   20   MODE M
   30   COLOUR 7
   40   PRINT "MODE" M
   45   PRINT
   50   FOR C=0 TO 63
   60     COLOUR C
   65     IF C MOD 32 = 0 THEN PRINT
   70     PRINT "#";
   80   NEXT 
   85   PRINT
   90   INPUT A
  100 NEXT
