program fjf56;

procedure foo (a, b: longint); attribute (name = 'Foo');
begin
  if (a = 1) and (b = 2) then
    writeln ('OK')
  else
    writeln ('failed');
end;

procedure bar (...); external name 'Foo';

begin
  bar (longint (1), longint (2))
end.
