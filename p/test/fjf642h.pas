program fjf642h;

type
  t (d: Integer) = Integer;

operator + (a, b: Integer) = c: t; external;  { WRONG }

begin
  WriteLn ('failed')
end.
