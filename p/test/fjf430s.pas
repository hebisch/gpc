program fjf430s;

begin
  {$local define foo 'OK'}
  {$ifdef foo}
  WriteLn (foo)
  {$endif}
  {$endlocal}
end.
