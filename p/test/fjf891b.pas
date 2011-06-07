program fjf891b;

type
  t = Cardinal attribute (Size = 12);

var
  a: packed array [1 .. 10] of t;
  d: Integer = 4;

begin
  WriteLn (SizeOf (a[d]))  { WRONG }
end.
