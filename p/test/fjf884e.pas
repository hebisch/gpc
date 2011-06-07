{$W no-object-assignment}

program fjf884e;

type
  a = object
    c: Integer;
  end;

  b = object (a)
    d: Integer;
  end;

var
  va: a;
  vb: b;

begin
  va.c := 2;
  vb.c := 4;
  vb.d := 6;
  va := vb;
  if (va.c = 4) and (vb.c = 4) and (vb.d = 6) then WriteLn ('OK') else WriteLn ('failed')
end.
