{ FLAG --extended-pascal }

program fjf754b (Output);

var
  a: Text;

begin
  WriteLn ('failed');
  if False then
    Rewrite (a, 'foo')  { WRONG }
end.
