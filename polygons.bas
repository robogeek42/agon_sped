   10 REM POLYGON
   20 REM JOHN A COLL
   30 REM VERSION 1 / 16 NOV 81
   40 MODE5
   50 VDU 19,1,1,0,0,0
   60 VDU 19,2,4,0,0 0
   70 VDU 19,3,3,0,0,0
   80 DIM X(10)
   90 DIM Y(10)
  110 FOR C=1 TO 2500
  120   xorigin=RND(1200)
  130   yorigin=RND(1000)
  140   VDU29,xorigin;yorigin;
  150   radius=RND(300)+50
  160   sides=RND(8)+2
  170   MOVE radius,0
  180   MOVE 10,10
  200   GCOL 0,0
  210   FOR SIDE=1 TO sides
  220     angle=(SIDE-1)*2*PI/sides
  230     X(SIDE)=radius*COS(angle)
  240     Y(SIDE)=radius*SIN(angle)
  250     MOVE0,0
  260     PLOT 85,X(SIDE), Y(SIDE)
  270   NEXT SIDE
  280   MOVE0,0
  290   PLOT 85,radius,0
  310   GCOL 0,RND(3)
  320   FOR SIDE=1 TO sides
  330     FOR line=SIDE TO sides
  340       MOVE X(SIDE), Y(SIDE)
  350       DRAW X(line), Y(line)
  360     NEXT line
  370   NEXT SIDE
  380 NEXT C
