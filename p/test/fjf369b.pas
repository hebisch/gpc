program fjf369b;

type
  a = restricted void; p = ^a;
  b = restricted void; q = ^b;

var
  u : p;
  w : q;

begin
  u := w; { WRONG }
  writeln ('failed')
end.
