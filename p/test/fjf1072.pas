program fjf1072 (Output);

procedure p (protected c: Char);
begin
  WriteLn (c, 'K')
end;

procedure q (protected s: String);
begin
  {$local W-} p (s) {$endlocal}
end;

begin
  q ('O')
end.
