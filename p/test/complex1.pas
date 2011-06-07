Program Complex1;

Var
  i: Complex;

begin
  i := -1;
  i := SqRt (i);
  if Sqr (i) = -1 then
    WriteLn ('OK')
  else
    WriteLn ('failed');
end.
