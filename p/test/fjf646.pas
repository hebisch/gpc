program fjf646;

type
  o = object
    procedure a;
  end;

  oo = object (o)
    procedure b;
  end;

procedure o.a;
begin
end;

procedure oo.b;
begin
  a := 0  { WRONG }
end;

begin
  WriteLn ('failed')
end.
