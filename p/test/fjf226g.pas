program fjf226g;
{$B-}
begin
  InOutRes := 1;
  if false and (IOResult >= 0) then
    writeln ('failed')
  else if IOResult = 0 then
    writeln ('failed')
  else
    writeln ('OK')
end.
