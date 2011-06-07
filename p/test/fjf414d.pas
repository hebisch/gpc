program fjf414d;
var c : Char;
begin
  c := #0;
  repeat c := {$W-} #$4funtil {$W+} True;
  WriteLn (c, 'K')
end.
