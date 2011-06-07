program fjf352;

type
  p = ^t;
  t (y : Integer) = array [1 .. y] of Integer;

var
  p1 : p;
  f : t; { WRONG }

begin
  WriteLn ('failed')
end.
