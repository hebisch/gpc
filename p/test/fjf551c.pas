{ FLAG -Werror }

program fjf551c;

function x: Integer;
begin
  x := 42
end;

begin
  if {$local W-} (Frac (x) = 0) {$endlocal} then WriteLn ('OK') else WriteLn ('failed')
end.
