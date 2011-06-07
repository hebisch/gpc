{ Note: Under BP, v1.b = 5 in the end. This is due to the buggy feature,
  as described in fjf451h.pas. Since GPC does not duplicate this bug, we
  get v1.b = 3 here. }

program fjf451g;

type
  o = object
    a : Integer;
    constructor c;
  end;

  o1 = object (o)
    b : Integer;
  end;

  o2 = object (o1)
    d : Integer;
  end;

constructor o.c;
begin
end;

var
  v1 : o1;
  v2 : o2;

procedure p (var v : o);
begin
  {$local W-} v := v2 {$endlocal}
end;

begin
  v1.c;
  v1.a := 2;
  v1.b := 3;
  v2.c;
  v2.a := 4;
  v2.b := 5;
  v2.d := 6;
  p (v1);
  if (v1.a = 4) and (v1.b = 3) and (v2.a = 4) and (v2.b = 5) and (v2.d = 6)
    and (TypeOf (v1) = TypeOf (o1))
    and (TypeOf (v2) = TypeOf (o2)) then
    WriteLn ('OK')
  else
    WriteLn ('failed ', v1.a, ', ', v1.b, ', ', v2.a, ', ', v2.b, ', ', v2.d, ', ',
             PtrInt (TypeOf (v1)), ', ', PtrInt (TypeOf (o1)), ', ',
             PtrInt (TypeOf (v2)), ', ', PtrInt (TypeOf (o2)))
end.
