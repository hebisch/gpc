{$delphi,B-}

program fjf1022e;

var
  Result: Integer;

function f: Integer;
begin
  f := 1;
  Result := 2
end;

begin
  Result := 3;
  if (f = 2) and (Result = 3) then WriteLn ('OK') else WriteLn ('failed')
end.
