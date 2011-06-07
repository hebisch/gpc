program fjf642n;

operator + (a, b: Integer); external;  { WRONG }

begin
  WriteLn ('failed')
end.
