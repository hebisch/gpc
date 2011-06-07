program fjf891c;

type
  t = Cardinal attribute (Size = 12);

var
  a: packed array [1 .. 10] of t;

begin
  WriteLn (SizeOf (a[2]))  { WRONG }
end.
