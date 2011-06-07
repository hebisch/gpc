program fjf829g;

type
  t = object
    destructor d;
  end;

procedure t.d;  { WRONG }
begin
end;

begin
end.
