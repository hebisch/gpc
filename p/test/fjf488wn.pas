program fjf488wn;

begin
  WriteLn ('failed');
  halt;
  WriteLn (SubStr ('foo', 1, 'a'))  { WRONG }
end.
