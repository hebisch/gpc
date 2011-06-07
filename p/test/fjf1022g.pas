{$delphi,B-,no-implicit-result}

program fjf1022g;

var
  Result: Integer;

function f: Integer;
begin
  f := 1;
  Result := 2
end;

begin
  Result := 3;
  if (f = 1) and (Result = 2) then WriteLn ('OK') else WriteLn ('failed')
end.
