program fjf526b;

var
  f: file;
  a, b: LongInt;

begin
  b := 1 shl BitSizeOf (CInteger) + 1;
  Rewrite (f, 1);
  BlockWrite (f, a, b and $ffffffff);
  WriteLn ('OK')
end.
