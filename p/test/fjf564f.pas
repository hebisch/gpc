program fjf564f;

var
  f: file [ByteInt] of Integer;
  i: Integer = 2;

begin
  Rewrite (f);
  Write (f, i, i, i, i);
  Reset (f);
  Read (f, i);
  if (FileSize (f) = 4) and (FilePos (f) = 1) and (LastPosition (f) = -125) and (Position (f) = -127) then
    WriteLn ('OK')
  else
    WriteLn ('failed ', FileSize (f), ' ', FilePos (f), ' ', LastPosition (f), ' ', Position (f))
end.
