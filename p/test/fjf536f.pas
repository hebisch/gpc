{$borland-pascal}

program fjf536f;
var s: String [10];
begin
  {$local gnu-pascal}
  WriteStr (s, 'OK');
  {$endlocal}
  WriteLn (s)
end.
