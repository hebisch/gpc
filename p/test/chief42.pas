Program OOPBug;
Type
TStrings = Object
  Procedure foo(const p : TStrings);
  Procedure foo2(protected var p : TStrings);
  Procedure foo3(var p : TStrings);
  Procedure bar;
End;

TStringList = Object(TStrings)
End;

Procedure TStrings.foo;
Begin
End;

Procedure TStrings.foo2;
Begin
End;

Procedure TStrings.foo3;
Begin
End;

Procedure TStrings.bar;
var
L : TStringList;
I : TStrings;
Begin
  foo(L);  { causes error }
  foo2(L);  { causes error }
  foo3(L);

  foo(I);
  foo2(I);
  foo3(I);
End;

Begin
  WriteLn ('OK')
End.
