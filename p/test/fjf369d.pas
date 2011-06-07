program fjf369d;

type
  a = restricted void; p = ^a;
  b = restricted void; q = ^b;

var
  u : p;

procedure foo (const w : q);
begin
end;

begin
  foo (u); { WRONG }
  writeln ('failed')
end.
