program fjf915aa;

type
  t = object
    destructor Done (a: Boolean);
  end;

destructor t.Done (a: Boolean);
begin
end;

var
  p: ^t;

begin
  Dispose (p, Done (Done))  { WRONG }
end.
