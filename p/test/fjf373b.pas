program fjf373b;

var
  a : ^cardinal;
  b : -10 .. 10;

begin
  a := @b; { WRONG }
  WriteLn ('failed')
end.
