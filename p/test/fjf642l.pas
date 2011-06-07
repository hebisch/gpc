program fjf642l;

type
  t (d: Integer) = Integer;

var
  a: function: t;  { WRONG }

begin
  a := a;
  WriteLn ('failed')
end.
