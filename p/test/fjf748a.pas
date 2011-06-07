program fjf748a;

type
  t = object
  end;

  u = object (t)
  end;

var
  a: array [1 .. 2] of t;

begin
  if a[1] is u { WARN } then WriteLn ('failed 1') else WriteLn ('failed 2')
end.
