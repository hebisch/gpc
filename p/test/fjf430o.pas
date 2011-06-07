program fjf430o;

begin
  {$local local X+} { WRONG }
  {$endlocal}
  WriteLn ('failed')
end.
