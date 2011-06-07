program fjf915t;

type
  p = object
    destructor Done;
  end;

destructor p.Done;
begin
end;

var
  a: ^p;

begin
  Dispose (a, Cardinal (2))  { WRONG }
end.
