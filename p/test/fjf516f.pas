program fjf516f;

var
  s: String (10);

begin
  if '' <= s then;  { WARN }
  WriteLn ('failed')
end.
