program fjf430v;

begin
  {$define foo 'OK'}
  {$local define foo 'failed'}
  {$endlocal}
  WriteLn (foo)
end.
