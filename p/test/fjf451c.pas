program fjf451c;

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
  v := v1;  { WARN }
  WriteLn ('failed')
end.
