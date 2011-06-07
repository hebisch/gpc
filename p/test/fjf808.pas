{$W no-local-external}

program fjf808;

uses fjf808u;

type
  p = ^procedure;

function Foo: p;

  procedure Bar; external name 'baz';

begin
  Foo := @Bar
end;

begin
  Foo^
end.
