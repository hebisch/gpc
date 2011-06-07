program fjf536d;
var s: String [10];
begin
  {$local borland-pascal}
  WriteStr (s, 'failed');  { WRONG }
  {$endlocal}
  WriteLn (s)
end.
