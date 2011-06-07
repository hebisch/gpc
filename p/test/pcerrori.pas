program PCErrorI;

var
ch :char;
junk:file of char;

begin
{$local I-}
  ch:=junk^;
{$endlocal}
  if IOResult <> 0 then WriteLn ('OK') else WriteLn ('failed')
end.
