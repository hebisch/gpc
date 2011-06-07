program fjf569o;

procedure foo (const s: String);
begin
  WriteLn (s)
end;

var
  a: procedure (const s: String) = foo;

begin
  a ('OK')
end.
