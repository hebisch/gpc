{$implicit-result}

program fjf1022a;

var
  Result: Integer = 0;

function f: Integer;
begin
  Result := 42
end;

begin
  if (f = 42) and_then (Result = 0) then WriteLn ('OK') else WriteLn ('failed')
end.
