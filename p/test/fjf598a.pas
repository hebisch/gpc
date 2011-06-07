program fjf598a;

procedure p;
begin
end;

var
  v: procedure (s: Integer) = p;  { WRONG }

begin
  WriteLn ('failed')
end.
