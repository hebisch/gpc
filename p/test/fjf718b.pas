program fjf718b;

type
  t = object
    constructor Init;
  end;

constructor t.Init;
begin
  Init := False  { WRONG }
end;

begin
  WriteLn ('failed')
end.
