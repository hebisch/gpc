program fjf915g;

type
  p = object
    constructor Init;
  end;

constructor p.Init;
begin
end;

var
  a: ^p;

begin
  New (a, Sqr (1))  { WRONG }
end.
