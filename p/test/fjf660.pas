program fjf660;

type
  a = object end;
  b = object (a) end;
  pb = ^b;

var
  v: ^a;

begin
  v := New (pb);
  with v^ as b do WriteLn ('OK')
end.
