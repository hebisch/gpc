program fjf473b;

procedure bar (const s : String);
begin
  Insert ('x', s, 1)  { WRONG }
end;

begin
  WriteLn ('failed')
end.
