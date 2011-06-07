program fjf525a;

var
  a: array [1 .. 10] of Integer;
  p: ^Integer;
  c: Integer;

begin
  c := 0;
  {$local X+}
  for p := @a[1] to @a[10] do Inc (c);
  {$endlocal}
  if c <> 10 then
    WriteLn ('failed: ', c)
  else
    WriteLn ('OK')
end.
