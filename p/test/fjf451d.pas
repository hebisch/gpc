program fjf451d;

type
  o = object
    a : Integer;
    constructor c;
  end;

  o1 = object (o)
    b : Integer;
  end;

constructor o.c;
begin
end;

var
  v1 : o1;

{$W-}

procedure p (v : o);
begin
  if (v.a = 2) and (v1.a = 2) and (v1.b = 3)
    and (TypeOf (v) = TypeOf (o))
    and (TypeOf (v1) = TypeOf (o1))
  then
    WriteLn ('OK')
  else
    WriteLn ('failed ', v.a, ', ', v1.a, ', ', v1.b, ', ',
             PtrInt (TypeOf (v)), ', ', PtrInt (TypeOf (o)), ', ',
             PtrInt (TypeOf (v1)), ', ', PtrInt (TypeOf (o1)))
end;

begin
  v1.c;
  v1.a := 2;
  v1.b := 3;
  p (v1)
end.
