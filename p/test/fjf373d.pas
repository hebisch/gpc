program fjf373d;

var
  a : ^integer;
  b : -10 .. 10;

begin
  a := @b; { WRONG }
  WriteLn ('failed')
end.
