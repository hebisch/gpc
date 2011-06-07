program fjf642e;

operator + (a, b: Integer) = c: blah; external;  { WRONG }

begin
  WriteLn ('failed')
end.
