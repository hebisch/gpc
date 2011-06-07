program fjf373c;

var
  a : ^integer;
  b : 0 .. 10;

begin
  a := @b; { WRONG }
  WriteLn ('failed')
end.
