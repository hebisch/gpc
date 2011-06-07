program fjf451f;

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

procedure p (v : o);
begin
  WriteLn ('failed')
end;

var
  v1 : o1;

begin
  v1.c;
  p (v1) { WARN }
end.
