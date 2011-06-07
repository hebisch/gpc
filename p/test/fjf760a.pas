{$W no-local-external}

program fjf760a;

procedure o; attribute (name = 'o'); forward;
procedure o;
begin
  Write ('O')
end;

procedure k (c: Char); attribute (name = 'k'); forward;
procedure k (c: Char);
begin
  WriteLn (c)
end;

procedure foo; external name 'o';

procedure baz;

  procedure foo (c: Char); external name 'k';

begin
  foo ('K')
end;

begin
  foo;
  baz
end.
