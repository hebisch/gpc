program fjf748b;

type
  t = object
  end;

  u = object (t)
  end;

var
  a: record b: array [1 .. 2] of t end;

begin
  if a.b[1] is u { WARN } then WriteLn ('failed 1') else WriteLn ('failed 2')
end.
