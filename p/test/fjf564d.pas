program fjf564d;

var
  f: file [Boolean] of Integer;
  i: Integer = 2;

begin
  Rewrite (f);
  Write (f, i, i);
  Reset (f);
  if (FileSize (f) = 2) and (FilePos (f) = 0) and (LastPosition (f) = True) and (Position (f) = False) then
    WriteLn ('OK')
  else
    WriteLn ('failed ', FileSize (f), ' ', FilePos (f), ' ', LastPosition (f), ' ', Position (f))
end.
