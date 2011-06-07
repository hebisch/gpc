program fjf459b;

{$local W-}
procedure foo;
const s : array [1 .. 5] of String (42) = ('foo', 'barrrrrrrrrrrrrrrrrrr');
begin
end;
{$endlocal}

var
  j : Integer = 0;

begin
  j := 0;
  foo;
  if j = 0 then WriteLn ('OK') else WriteLn ('failed ', j)
end.
