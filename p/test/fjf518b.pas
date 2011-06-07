program fjf518b;
{$W-}
var i: Integer;
begin
  if {$local W-} i in [] then {$endlocal} WriteLn ('failed') else WriteLn ('OK')
end.
