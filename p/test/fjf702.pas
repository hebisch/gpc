program fjf702;

type
  t = object
    constructor i;
    procedure a;
    procedure foo;
    procedure bar; virtual;
    procedure baz; virtual;
  end;

  {$local W-}
  u = object (t)
    procedure foo; virtual;
  end;
  {$endlocal}

constructor t.i;
begin
end;

procedure t.a;
begin
  baz
end;

procedure t.foo;
begin
end;

procedure t.bar;
begin
  WriteLn ('failed')
end;

procedure t.baz;
begin
  WriteLn ('OK')
end;

procedure u.foo;
begin
  inherited foo
end;

var
  v: u;

begin
  v.a
end.
