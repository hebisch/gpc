program fjf267;

type
  t = array [1 .. 10] of Integer;

var
  i : Integer;
  p : ^t;

begin
  i := 1;
  var v : array [1 .. i] of Integer;
  p := @v; { WRONG }
  writeln ('failed')
end.
