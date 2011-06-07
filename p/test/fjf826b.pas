program fjf826b;

type
  t = object
    procedure p; attribute (noreturn);
  end;

procedure t.p;
begin
  { WARN, returns }
end;

begin
end.
