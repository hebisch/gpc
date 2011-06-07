program fjf598b;

procedure p;
begin
end;

var
  v: procedure (s: Integer);

begin
  v := p;  { WRONG }
  WriteLn ('failed')
end.
