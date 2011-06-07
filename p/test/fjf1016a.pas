program fjf1016a (Output);

type
  i2 = Integer value 2;
  i4 = Integer value 4;

  a = record
    b: i2;
    c: i4
  end;

  b = a value [b: 1; c: 9];

  c = a value [b: 6];

var
  va: a;
  vb: b;
  vc: c;
  vd: a value [b: 3];
  ve: b value [c: 5];
  vf: c value [c: 7];

begin
  if (va.b = 2) and (va.c = 4) and (vb.b = 1) and (vb.c = 9)
     and (vc.b = 6) and (vd.b = 3) and (ve.c = 5) and (vf.c = 7) then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end.
