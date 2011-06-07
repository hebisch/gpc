program fjf793e;

procedure External (const s: String);
begin
  WriteLn (s)
end;

begin
  var a: String (2) = 'OK';
  External (a)
end.
