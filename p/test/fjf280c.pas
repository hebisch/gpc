program fjf280c;

type
  o = object
        procedure m (i : integer);
      end;

procedure o.m (i : integer);
var i : integer; { WRONG }
begin
end;

begin
  writeln ('failed')
end.
