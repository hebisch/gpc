{ FLAG --extended-pascal }

program fjf754c (Output);

var
  a: Text;

begin
  WriteLn ('failed');
  if False then
    Extend (a, 'foo')  { WRONG }
end.
