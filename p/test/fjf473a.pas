program fjf473a;

procedure bar (const s : String);
begin
  Delete (s, 1, 1)  { WRONG }
end;

begin
  WriteLn ('failed')
end.
