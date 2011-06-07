program fjf518c;

function i: Integer;
begin
  i := 42
end;

begin
  if {$local W-} i in [] then {$endlocal}
    WriteLn ('failed 1')
  else
    WriteLn ('OK')
end.
