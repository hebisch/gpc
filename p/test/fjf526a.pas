program fjf526a;

var
  f: file;
  a, b: LongInt;

begin
  b := 1 shl BitSizeOf (CInteger) + 1;
  Rewrite (f, 1);
  BlockWrite (f, a, SizeOf (a));
  Reset (f, 1);
  BlockRead (f, a, b and $ffffffff);
  WriteLn ('OK')
end.
