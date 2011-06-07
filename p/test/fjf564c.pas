program fjf564c;

var
  f: file [(k, l, m, n, o, p, q)] of Integer;
  i: Integer = 2;

begin
  Rewrite (f);
  Write (f, i, i, i, i);
  Reset (f);
  Read (f, i);
  if (FileSize (f) = 4) and (FilePos (f) = 1) and (LastPosition (f) = n) and (Position (f) = l) then
    WriteLn ('OK')
  else
    WriteLn ('failed ', FileSize (f), ' ', FilePos (f), ' ',
             Succ ('k', Ord (LastPosition (f))), ' ', Succ ('k', Ord (Position (f))))
end.
