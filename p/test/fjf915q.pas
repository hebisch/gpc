program fjf915q;

type
  p = object
    constructor Init;
  end;

constructor p.Init;
begin
end;

var
  a: ^p;
  b: Pointer = nil;

begin
  New (a, Assigned (b))  { WRONG }
end.
