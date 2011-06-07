program fjf645b;

type
  a = object end;
{$local W-}
  b = abstract object (a) end;
{$endlocal}

begin
  WriteLn ('OK')
end.
