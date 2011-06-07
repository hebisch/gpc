program fjf657b;

type
  TString = String (42);

function foo: TString;
begin
  foo := 'OK'
end;

procedure bar (const s: String);
begin
  WriteLn (s)
end;

begin
  bar (foo)
end.
