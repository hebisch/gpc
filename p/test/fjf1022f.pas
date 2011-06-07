{$implicit-result}

program fjf1022f;

var
  Result: Integer = 0;

function f: Integer;
begin
  f := 42;
  Result := Result + 1;
end;

begin
  if (f = 43) and_then (Result = 0) then WriteLn ('OK') else WriteLn ('failed')
end.
