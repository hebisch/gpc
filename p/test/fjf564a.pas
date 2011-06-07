program fjf564a;

var
  f: file [10 .. 20] of Integer;
  i: Integer = 2;

begin
  Rewrite (f);
  Write (f, i, i, i, i);
  Reset (f);
  Read (f, i);
  if (FileSize (f) = 4) and (FilePos (f) = 1) and (LastPosition (f) = 13) and (Position (f) = 11) then
    WriteLn ('OK')
  else
    WriteLn ('failed ', FileSize (f), ' ', FilePos (f), ' ', LastPosition (f), ' ', Position (f))
end.
