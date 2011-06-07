program AvO3;

var
  i, n: Integer;
  a: array [1 .. 10] of Integer = (3, -2, 5, 42, -5, -2, -6, 3, 9, -10);

BEGIN

n := 0;
FOR i := 1 TO 10 DO
BEGIN
 IF a[i]<=0 THEN CYCLE;
 n := n + a[i]
END;

i := 1;
WHILE i<63 DO
BEGIN
 IF a[i]=42 THEN LEAVE;
 i := i+1
END;

IF (i = 4) and (n = 62) THEN WriteLn ('OK') else WriteLn ('failed')

END.
