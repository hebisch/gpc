program fjf915t;

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
  New (a, Cardinal (2))  { WRONG }
end.
