program fjf915f;

type
  p = object
    constructor Init;
  end;

constructor p.Init;
begin
end;

var
  a:^p;

begin
  New (a, 1)  { WRONG }
end.
