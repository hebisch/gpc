program fjf740;

begin
  WriteLn ('failed');
  Halt;
  goto (42)  { WRONG }
end.
