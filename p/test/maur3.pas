program maur3;

{ FLAG -O0 }

procedure foo; attribute (inline, name = 'bar');
begin
  writeln('OK')
end;

begin
  foo
end.
