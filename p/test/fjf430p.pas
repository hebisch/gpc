program fjf430p;

begin
  {$local X+,local X+} { WRONG }
  {$endlocal}
  WriteLn ('failed')
end.
