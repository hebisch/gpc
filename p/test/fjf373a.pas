program fjf373a;

var
  a : ^cardinal;
  b : 0 .. 10;

begin
  a := @b; { WRONG }
  WriteLn ('failed')
end.
