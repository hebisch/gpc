Program BO4_9;

{$W-}

uses
  BO4_9u in 'bo4-9u.pas';

begin
  Foo:= Foo or Foo;
  writeln ( 'OK' );
end.
