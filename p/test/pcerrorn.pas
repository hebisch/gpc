program PCErrorN (output);

var
ch :char;

begin
{$local I-}
read(output,ch);
{$endlocal}
  if IOResult <> 0 then WriteLn ('OK') else WriteLn ('failed')
end.
