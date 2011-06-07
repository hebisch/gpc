program fjf430n;

begin
  {$local if 1} { WRONG }
  {$endif}
  {$endlocal}
  WriteLn ('failed')
end.
