program fjf414a;
var i : integer;
begin
  i := 0;
  repeat i := {$W-} 1until {$W+} True;
  if i = 1 then WriteLn ('OK') else WriteLn ('failed')
end.
