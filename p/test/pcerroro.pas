program PCErrorO (input);

var
ch :char;

begin
{$local I-}
write(input,ch);
{$endlocal}
  if IOResult <> 0 then WriteLn ('OK') else WriteLn ('failed')
end.
