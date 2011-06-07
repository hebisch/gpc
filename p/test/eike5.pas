program Foo;
var
  f: File;
  i, v: Integer;
begin
  Assign (f, 'foo.dat');
  Rewrite (f, SizeOf (Integer));
  v := 101;
  for i := 0 to 10 do
    BlockWrite (f, v, 1);
  Close (f);
  Reset (f, SizeOf (Integer));
  while not EOF (f) do
    begin
      BlockRead (f, v, 1);
      WriteLn (v)
    end;
  Close (f)
end.
