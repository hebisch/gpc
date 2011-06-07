program fjf737b;

var
  c: Integer = 0;

function f: Byte;
begin
  Inc (c);
  f := 0
end;

begin
  {$local W-} if 1 in ([f] + [2]) then WriteLn ('failed 1'); {$endlocal}
  if c = 1 then WriteLn ('OK') else WriteLn ('failed')
end.
