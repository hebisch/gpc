{ Fixed some bugs in the test program (which also show under BP).
  Frank, 20030610 }

{ Objects as value parameters }

{$borland-pascal}

Program Chief35a;
Type
TStrings = Object
  I : Integer;
  Constructor C (a : Integer);
  Procedure foo(Const p : TStrings; v : Integer; t : Pointer);
  Procedure foo2(p : TStrings; v : Integer; t : Pointer);
  Procedure foo3(Var p : TStrings; v : Integer; t : Pointer);
  Procedure bar;
End;

TStringList = Object(TStrings)
  j : Integer;
End;

Constructor TStrings.C (a : Integer);
Begin
  I := a
End;

Procedure TStrings.foo;
Begin
  if (p.I <> v) or (TypeOf (p) <> t) then
    Begin
      WriteLn ('failed foo ', v);
      Halt
    End
End;

Procedure TStrings.foo2;
Begin
  if (p.I <> v) or (TypeOf (p) <> t) then
    Begin
      WriteLn ('failed foo2 ', v);
      Halt
    End;
  Inc (p.I)
End;

Procedure TStrings.foo3;
Begin
  if (p.I <> v) or (TypeOf (p) <> t) then
    Begin
      WriteLn ('failed foo3 ', v);
      Halt
    End;
  Inc (p.I)
End;

Procedure TStrings.bar;
Var
L : TStringList;
K : TStrings;
Begin
  L.C (42);
  K.C (17);
  foo(L, 42, TypeOf (TStringList));  { causes error }
  foo2(L, 42, TypeOf (TStrings)); { causes error }
  foo3(L, 42, TypeOf (TStringList));
  foo3(L, 43, TypeOf (TStringList));

  foo(K, 17, TypeOf (TStrings));
  foo2(K, 17, TypeOf (TStrings));
  foo3(K, 17, TypeOf (TStrings));
  foo3(K, 18, TypeOf (TStrings));
End;

Var
  x : TStrings;

Begin
  x.bar;
  WriteLn ('OK')
End.
