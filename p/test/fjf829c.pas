program fjf829c;

type
  t = object
    destructor r;
  end;

destructor t.r;
begin
  WriteLn ('OK')
end;

var
  p: ^t;

begin
  Dispose (p, r)
end.
