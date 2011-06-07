Program BO5_9;

uses
  BO5_9u in 'bo5-9u.pas',
  BO5_9v in 'bo5-9v.pas';

Var
  Foo: FooPtr;

begin
  Foo:= New ( BarPtr, Init );
  Foo^.OK ( Nil );
end.
