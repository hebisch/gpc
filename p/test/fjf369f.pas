program fjf369f;

type
  a = restricted void; p = ^a;
  b = restricted void; q = ^b;

var
  u : p;

procedure foo (var w : q);
begin
end;

begin
  foo (u); { WRONG }
  writeln ('failed')
end.
