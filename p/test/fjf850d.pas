program fjf850d;

function foo = a: Integer; forward;

function foo;
begin
  a := 42
end;

begin
  if foo = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
