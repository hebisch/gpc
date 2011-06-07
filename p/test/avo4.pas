PROGRAM PatTest;
TYPE Pattern = packed array [0..7] of 0..255;
VAR pat: array[0..7] of Pattern;

PROCEDURE MakePatterns;
 VAR
    i, j: Integer;
 BEGIN
   j := 0;
   FOR i := 0 TO 7 DO
  BEGIN
   pat[i][(j + 0) mod 8] := $12;
   pat[i][(j + 1) mod 8] := $23;
   pat[i][(j + 2) mod 8] := $34;
   pat[i][(j + 3) mod 8] := $45;
   pat[i][(j + 4) mod 8] := $56;
   pat[i][(j + 5) mod 8] := $67;
   pat[i][(j + 6) mod 8] := $78;
   pat[i][(j + 7) mod 8] := $89;
   j := j + 1;
    END;
 END;

BEGIN
 MakePatterns;
 if (pat[0, 0] = $12) and
    (pat[1, 2] = $23) and
    (pat[2, 4] = $34) and
    (pat[3, 6] = $45) and
    (pat[3, 7] = $56) and
    (pat[4, 1] = $67) and
    (pat[5, 3] = $78) and
    (pat[6, 5] = $89) then WriteLn ('OK') else WriteLn ('failed')
END.
