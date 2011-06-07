program fjf451a;

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
  v : o;
  v1 : o1;

begin
  v.c;
  v1.c;
  v.a := 1;
  v1.a := 2;
  v1.b := 3;
  {$local W-} v := v1; {$endlocal}
  if (v.a = 2) and (v1.a = 2) and (v1.b = 3)
    and (TypeOf (v) = TypeOf (o))
    and (TypeOf (v1) = TypeOf (o1)) then
    WriteLn ('OK')
  else
    WriteLn ('failed ', v.a, ', ', v1.a, ', ', v1.b, ', ',
             PtrInt (TypeOf (v)), ', ', PtrInt (TypeOf (o)), ', ',
             PtrInt (TypeOf (v1)), ', ', PtrInt (TypeOf (o1)))
end.
