program ArrayAssignment;

var
  a, b : array [9 .. 10] of Integer;

begin
  b [10] := 10;
  a [10] := 3;
  a [9] := 2;
  b := a;
  b [9] := 9;
  if (a [10] = 3) and (a [9] = 2) and (b [10] = 3) and (b [9] = 9)
    then WriteLn ('OK')
    else WriteLn ('failed')
end.
