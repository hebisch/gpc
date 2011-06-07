program fjf903a;

type
  a = object
    procedure p;
  end;

  pb = ^b;
  b = object (a)
    procedure p;
  end;

procedure a.p;
begin
  WriteLn ('OK')
end;

procedure b.p;
begin
  WriteLn ('failed')
end;

var
  v: ^a;

begin
  v := New (pb);
  v^.p
end.
