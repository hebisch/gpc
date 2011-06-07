program fjf915qq;

type
  p = object
    destructor Done;
  end;

destructor p.Done;
begin
end;

var
  a: ^p;
  b: Pointer = nil;

begin
  Dispose (a, Assigned (b))  { WRONG }
end.
