Program WarnAlign;

Var
  foo: Byte;
  bar: Integer absolute foo;  { WARN }

begin
  writeln ( 'failed' );
end.
