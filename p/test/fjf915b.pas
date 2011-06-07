program fjf915b;

type
  t = object
    constructor Init (a: Boolean);
  end;

function Init (a: Boolean): Boolean;
begin
  Init := not a
end;

constructor t.Init (a: Boolean);
begin
  if not a then Fail;
  WriteLn ('OK')
end;

var
  p: ^t;

begin
  New (p, Init (Init (False)))
end.
