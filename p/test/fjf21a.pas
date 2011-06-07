{ FLAG -Werror }

Program fjf21a;

{$borland-pascal }

Procedure Foo; near;
begin
  writeln ( Concat ( 'O', 'K' ) );
end;

begin
  Foo;
end.
