{$W float-equal}

program fjf712b;

var
  a: Real = 2;
  b: Real = 3;
  c: Real = 5;

begin
  if a <> c { WARN } then WriteLn ('failed 1') else WriteLn ('failed 2')
end.
