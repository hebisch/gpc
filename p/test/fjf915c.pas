program fjf915c;

type
  t = object
    constructor Init;
    destructor Done; virtual;
  end;

  pu = ^u;
  u = object (t)
    destructor Done; virtual;
  end;

constructor t.Init;
begin
end;

destructor t.Done;
begin
  WriteLn ('failed')
end;

destructor u.Done;
begin
  WriteLn ('OK')
end;

var
  p: ^t;

begin
  p := New (pu, Init);
  Dispose (p, Done)
end.
