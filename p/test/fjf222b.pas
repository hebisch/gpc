program fjf222b;

type
  IntGE4 = 4 .. MaxInt;

procedure x (a:IntGE4);
var c:array[4..a] of Integer;
begin
  c[4]:=0
end;

begin
  x(1)  { WRONG }
end.
