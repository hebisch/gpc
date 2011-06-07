program fjf642o;

type
  t (d: Integer) = Integer;

var
  a: function;  { WRONG }

begin
  a := a;
  WriteLn ('failed')
end.
