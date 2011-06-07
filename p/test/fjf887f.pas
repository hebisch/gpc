program fjf887f;

type
  r = 1 .. 10;

procedure f (var a: array [b .. c: r] of Integer);
begin
end;

var
  a: array [1 .. 11] of Integer;

begin
  f (a)  { WRONG }
end.
