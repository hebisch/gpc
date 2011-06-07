program fjf369h;

type
  a = restricted void; p = ^a;
  b = restricted void; q = ^b;

var
  u : p;
  w : q;

begin
  if u = w then Write (' '); { WRONG }
  writeln ('failed')
end.
