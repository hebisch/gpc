program fjf526d;

var
  f: file;
  a: LongInt;
  b: Cardinal;

begin
  Rewrite (f, 1);
  BlockWrite (f, a, SizeOf (a), b);
  if b <> SizeOf (a) then
    begin
      WriteLn ('failed 1: ', b);
      Halt
    end;
  Reset (f, 1);
  BlockRead (f, a, SizeOf (a), b);
  if b = SizeOf (a) then
    WriteLn ('OK')
  else
    WriteLn ('failed 2: ', b)
end.
