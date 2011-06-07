program fjf665h;

begin
  Assert (True);
  {$local no-assertions} Assert (False); {$endlocal}
  Assert (True);
  WriteLn ('OK')
end.
