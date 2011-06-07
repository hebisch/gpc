program fjf826e;

type
  t = object
    procedure p; attribute (noreturn); attribute (name = 'foo');
  end;

procedure t.p;
begin
  { WARN, returns }
end;

begin
end.
