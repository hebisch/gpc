program PCErrorH;

var
junk:file of char;

begin
{$local I-}
          rewrite(junk);
          reset(junk);
          get(junk);
          get(junk);
          write(junk^);
{$endlocal}
  if IOResult <> 0 then WriteLn ('OK') else WriteLn ('failed')
end.
