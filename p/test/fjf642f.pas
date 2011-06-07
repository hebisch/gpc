program fjf642f;

operator + (a, b: Integer) = c: Text; external;  { WRONG }

begin
  WriteLn ('failed')
end.
