program fjf891d;

type
  t = Cardinal attribute (Size = 12);

var
  b: packed record c: t end;

begin
  WriteLn (SizeOf (b.c))  { WRONG }
end.
