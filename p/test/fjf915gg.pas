program fjf915gg;

type
  p = object
    destructor Done (a: Boolean);
  end;

destructor p.Done (a: Boolean);
begin
end;

var
  a:^p;

begin
  Dispose (a, Sqr (1))  { WRONG }
end.
