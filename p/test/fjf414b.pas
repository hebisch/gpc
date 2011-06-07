program fjf414b;
var i : integer;
begin
  i := 0;
  repeat i := {$W-} $funtil {$W+} True;
  if i = $f then WriteLn ('OK') else WriteLn ('failed')
end.
