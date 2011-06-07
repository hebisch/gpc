program fjf477;

function foo : Real;
begin
  foo := 42
end;

procedure bar (z : Complex);
begin
  if z = 42 then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  bar (foo)
end.
