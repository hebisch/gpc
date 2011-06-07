program chief27;
var
s:string[5];
begin
  s := 'Fred';
  if not (s = '') and not {$local W-}(s < '') and{$endlocal} (s > '')
     and (s <> '') and {$local W-}(s >= '') and{$endlocal} not (s <= '')
    then writeln('OK')
    else writeln('failed')
end.
