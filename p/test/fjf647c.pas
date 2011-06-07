program fjf647c;

function f: Integer;
begin
  f := 1
end;

function g: Integer;
begin
  g := 2
end;

begin
  if Odd (f) and not Odd (g) then WriteLn ('OK') else WriteLn ('failed')
end.
