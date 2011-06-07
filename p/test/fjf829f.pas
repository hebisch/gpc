program fjf829f;

type
  t = object
    constructor d;
  end;

function t.d: Boolean;  { WRONG }
begin
  d := False
end;

begin
end.
