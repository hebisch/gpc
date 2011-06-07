program fjf834;

type
  a = 1 .. 10;
  b = 1 .. 10;

var
  v: b;

procedure p (var v: a);
begin
end;

begin
  p (v)  { WRONG }
end.
