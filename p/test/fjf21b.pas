Program fjf21a;

Procedure Foo; near; { WARN }
begin
  writeln ('failed');
end;

begin
  Foo;
end.
