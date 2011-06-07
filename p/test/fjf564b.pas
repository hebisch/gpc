program fjf564b;

var
  f: file ['d' .. 'y'] of Integer;
  i: Integer = 2;

begin
  Rewrite (f);
  Write (f, i, i, i, i);
  Reset (f);
  Read (f, i);
  if (FileSize (f) = 4) and (FilePos (f) = 1) and (LastPosition (f) = 'g') and (Position (f) = 'e') then
    WriteLn ('OK')
  else
    WriteLn ('failed ', FileSize (f), ' ', FilePos (f), ' ', LastPosition (f), ' ', Position (f))
end.
