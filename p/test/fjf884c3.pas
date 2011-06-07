{$W no-object-assignment}

program fjf884c3;

type
  a = object
    constructor i;
    procedure p; virtual;
  end;

  b = object (a)
    procedure p; virtual;
  end;

constructor a.i;
begin
end;

procedure a.p;
begin
  WriteLn ('OK')
end;

procedure b.p;
begin
  WriteLn ('failed')
end;

procedure p (t: a);
begin
  t.p
end;

var
  w: b;

begin
  p (w)
end.
