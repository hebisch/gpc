{ FLAG --borland-pascal }

program fjf536k;
var s: String [10];
begin
  {$local borland-pascal}
  {$endlocal}
  WriteStr (s, 'failed');  { WRONG }
  WriteLn (s)
end.
