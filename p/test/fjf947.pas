{$classic-pascal}

program fjf947 (Output);

function foo: Integer;
begin
  foo := 42
end;

procedure bar (function foo: Integer);
begin
  if foo = 42 then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  bar (foo)
end.
