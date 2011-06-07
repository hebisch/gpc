{$W float-equal}

program fjf712c;

var
  a: Real = 2;
  b: Real = 3;
  c: Real = 5;

begin
  if a + b = c { WARN } then WriteLn ('failed 1') else WriteLn ('failed 2')
end.
