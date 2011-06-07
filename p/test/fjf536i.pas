{ FLAG --borland-pascal }

program fjf536i;
var s: String [10];
begin
  {$local gnu-pascal}
  {$endlocal}
  WriteStr (s, 'failed');  { WRONG }
  WriteLn (s)
end.
