Program BO4_8;

uses
  BO4_8v in 'bo4-8v.pas',
  BO4_8u in 'bo4-8u.pas';

Type
  BarObj = object ( FoooObj )
    Procedure FooBar ( Var F: FooObj );
  end { BarObj };

Var
  Foo: BarObj;

Procedure BarObj.FooBar;

begin { BarObj.FooBar }
  writeln ( O, K );
end { BarObj.FooBar };

begin
  Foo.O:= 'O';
  Foo.K:= 'K';
  Foo.FooBar ( Foo );
end.
