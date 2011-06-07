program fjf414c;
var c : Char;
begin
  c := #0;
  repeat c := {$W-} #79until {$W+} True;
  WriteLn (c, 'K')
end.
