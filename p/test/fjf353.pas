program fjf353;

{ Bug since 19990618 }

type
  p = ^t;
  t (y : Integer) = array [1 .. y] of Integer;

var
  p1 : p; { not used, but triggers the bug }

procedure foo (a : t);
begin
  if a.y = 10 then writeln ('OK') else writeln ('failed')
end;

var
  f : t (10);

begin
  p1 := p1;
  foo (f)
end.
