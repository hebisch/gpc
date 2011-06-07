{ GPC-style routine pointers on the one hand and BP-style routine types
  and SP-style routine parameters on the other hand are distinct things.
  Currently GPC allows conversion between them only via a routine
  variable with the special, BP-style, meaning of `@' as shown here
  (or via type-casts, but without type-safety). I'm not convinced that
  anything more is needed. -- Frank }

program fjf455;

procedure ok;
begin
  WriteLn ('OK')
end;

var
  y : ^procedure = @ok;
  z : procedure;

procedure foo (procedure p);
begin
  p
end;

begin
  { foo (y)   doesn't work }
  { foo (y^)  doesn't work }

  {$local W-} @z := y; {$endlocal}
  foo (z)
end.
