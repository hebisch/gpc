program fjf871;

var
  s1, s2: String (10);

begin
  if SeekEOLn then WriteLn ('failed 1');
  Read (s1);
  if not SeekEOLn then WriteLn ('failed 2');
  ReadLn;
  if not SeekEOLn then WriteLn ('failed 3');
  if SeekEOF then WriteLn ('failed 4');
  Read (s2);
  if not SeekEOF then WriteLn ('failed 5');
  WriteLn (s1, s2)
end.
