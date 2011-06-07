{ FLAG -O3 }

program fjf652;

var
  a: array [1 .. 10] of Integer;

begin
  if a = '' then WriteLn ('failed')  { WRONG }
end.
