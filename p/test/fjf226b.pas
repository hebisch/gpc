program fjf226b;
{$B-}
var i: Integer = -1;
begin
  if true or (Copy ('bar', i, 1) = 'foo') then WriteLn ('OK')
end.
