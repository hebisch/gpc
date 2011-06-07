program fjf226j;

{$B-}

type
  t = array [1 .. sizeof (text) div sizeof (integer)] of integer;

var
  f : text;
  a : t absolute f;
  save : t;
  i : integer;

begin
  save := a;
  for i := 1 to high (a) do a [i] := 0;
  if false and (binding (f).name = 'foo') then writeln ('failed') else writeln ('OK');
  a := save
end.
