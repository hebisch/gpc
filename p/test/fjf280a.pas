program fjf280a;

type
  o = object
        i : integer;
        procedure m (i : integer); { WRONG }
      end;

procedure o.m (i : integer);
begin
end;

begin
  writeln ('failed')
end.
