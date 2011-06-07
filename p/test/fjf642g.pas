program fjf642g;

operator + (a, b: Integer) = c: String; external;  { WARN }

begin
  WriteLn ('failed')
end.
