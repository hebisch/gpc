program fjf915ff;

type
  p = object
    destructor Done;
  end;

destructor p.Done;
begin
end;

var
  a:^p;

begin
  Dispose (a, 1)  { WRONG }
end.
