{ FLAG --borland-pascal }

program fjf536g;
var s: String [10];
begin
  {$local gnu-pascal}
  WriteStr (s, 'OK');
  {$endlocal}
  WriteLn (s)
end.
