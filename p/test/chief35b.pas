{ Fixed some bugs, cf. chief35a.pas.
  Frank, 20030610 }

{ Objects as value parameters }

{$W-}

Program Chief35b;
Type
TStrings = Object
  i : Integer;
  Constructor c (a : integer);
  Procedure foo(Const p : TStrings; v : Integer; t : Pointer);
  Procedure foo2(p : TStrings; v : Integer; t : Pointer);
  Procedure foo3(Var p : TStrings; v : Integer; t : Pointer);
  Procedure foo4(Protected p : TStrings; v : Integer; t : Pointer);
  Procedure foo5(Protected Var p : TStrings; v : Integer; t : Pointer);
  Procedure bar;
End;

TStringList = Object(TStrings)
  j : Integer;
End;

Constructor TStrings.c (a : integer);
begin
  i := a
end;

Procedure TStrings.foo;
Begin
  if (p.i <> v) or (TypeOf (p) <> t) then
    begin
      WriteLn ('failed foo ', v);
      Halt
    end
End;

Procedure TStrings.foo2;
Begin
  if (p.i <> v) or (TypeOf (p) <> t) then
    begin
      WriteLn ('failed foo2 ', v);
      Halt
    end;
  Inc (p.i)
End;

Procedure TStrings.foo3;
Begin
  if (p.i <> v) or (TypeOf (p) <> t) then
    begin
      WriteLn ('failed foo3 ', v);
      Halt
    end;
  Inc (p.i)
End;

Procedure TStrings.foo4;
Begin
  if (p.i <> v) or (TypeOf (p) <> t) then
    begin
      WriteLn ('failed foo4 ', v, ' ', PtrInt (TypeOf (p)), ' ', PtrInt (t));
      Halt
    end
End;

Procedure TStrings.foo5;
Begin
  if (p.i <> v) or (TypeOf (p) <> t) then
    begin
      WriteLn ('failed foo5 ', v);
      Halt
    end
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
  foo4(L, 43, TypeOf (TStrings));
  foo5(L, 43, TypeOf (TStringList));

  foo(K, 17, TypeOf (TStrings));
  foo2(K, 17, TypeOf (TStrings));
  foo3(K, 17, TypeOf (TStrings));
  foo4(K, 18, TypeOf (TStrings));
  foo5(K, 18, TypeOf (TStrings));
End;

Var
  x : TStrings;

Begin
  x.bar;
  WriteLn ('OK')
End.
