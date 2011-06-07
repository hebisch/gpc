program fjf430t;

begin
  {$local define foo 'failed'}
  {$endlocal}
  {$ifdef foo}
  WriteLn (foo)
  {$else}
  WriteLn ('OK')
  {$endif}
end.
