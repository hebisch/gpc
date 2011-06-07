program fjf430q;

begin
  {$X+,local X+} { WRONG }
  {$endlocal}
  WriteLn ('failed')
end.
