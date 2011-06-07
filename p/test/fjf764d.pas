program fjf764d;

function f = f: Integer;
begin
  f := 1;
  f := f + 1
end;

begin
  if f = 2 then WriteLn ('OK') else WriteLn ('failed')
end.
