program fjf430u;

begin
  {$define foo 'failed'}
  {$local define foo 'OK'}
  WriteLn (foo)
  {$endlocal}
end.
