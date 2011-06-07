program daj23(input,output);

const
      MAXCOMP=5;
      MAXROUND=2;
type
     TSMALLPOINT=RECORD
       REGNO:INTEGER;
       PNTS:ARRAY[1..MAXROUND] OF INTEGER;
       END;

const
    r : ARRAY [1 .. 18] OF INTEGER = (10, 0, 0, 101, 2, 3, 102, 3, 4, 103, 4, 5, 104, 5, 6, 105, 6, 7);

var
    I,J,ORDINAL:INTEGER;
    t:FILE OF INTEGER;

PROCEDURE SAVE_CAT;

var I,J:INTEGER;
    F:FILE OF TSMALLPOINT;

BEGIN

 REWRITE(F,'tmp.dat');

 F^.REGNO:=ORDINAL;
 FOR J:=1 TO MAXROUND DO
   F^.PNTS[J]:=0;

 PUT(F);

 FOR I:=1 TO MAXCOMP DO
  BEGIN
   F^.REGNO:=100+I;

   FOR J:=1 TO MAXROUND DO
    BEGIN
     F^.PNTS[J]:=I+J;
    END;

   PUT(F);
  END;

 CLOSE(F);
END;

BEGIN {daj23}
 ORDINAL:=10;
 SAVE_CAT;
 reset (t, 'tmp.dat');
 FOR I := 1 TO High (r) DO
   BEGIN
     Read (t, J);
     if J <> r [I] then
       BEGIN
         WriteLn ('failed ', I);
         Halt
       END
   END;
 WriteLn ('OK')
END. {daj23}
