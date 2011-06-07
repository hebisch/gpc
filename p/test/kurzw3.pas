program kurzw3;

var
  a : Integer = 42;

begin
  if {$local W-} (Trunc (a) = 42) and (Round (a) = 42) {$endlocal} then WriteLn ('OK') else WriteLn ('failed')
end.
