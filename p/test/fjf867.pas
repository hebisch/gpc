program fjf867;

var
  a: String (10); external name 'foo'; attribute (volatile);
  b: String (10); attribute (name = 'foo', volatile);

begin
  FillChar (b, SizeOf (b), 0);
  Initialize (a);
  b := 'OK';
  WriteLn (b)
end.
