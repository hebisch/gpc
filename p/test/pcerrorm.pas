program PCErrorM (Output);

var
i :integer;

begin
{$local I-, W-, extended-pascal}
          i:=-1;
          WriteLn(1.0:i);
{$endlocal}
  if IOResult <> 0 then WriteLn ('OK') else WriteLn ('failed')
end.
