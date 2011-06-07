program fjf175b;

var
  a : array [1 .. 2] of record b : Integer end = ((), ());

begin
  a := a;
  WriteLn ('OK')
end.
