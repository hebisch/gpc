program fjf280b;

type
  o = object
        i : integer;
        procedure m;
      end;

procedure o.m;
var i : integer; { WRONG }
begin
end;

begin
  writeln ('failed')
end.
