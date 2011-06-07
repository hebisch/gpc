{ FLAG --extended-pascal }

program fjf754a (Output);

var
  a: Text;

begin
  WriteLn ('failed');
  if False then
    Reset (a, 'foo')  { WRONG }
end.
