{$methods-always-virtual}

program fjf903f;

type
  a = object
    constructor c;
    destructor p;
  end;

  pb = ^b;
  b = object (a)
    destructor p;
  end;

constructor a.c;
begin
end;

destructor a.p;
begin
  WriteLn ('failed')
end;

destructor b.p;
begin
  WriteLn ('OK')
end;

var
  v: ^a;

begin
  v := New (pb);
  Dispose (v, p)
end.
