{$extended-pascal}

program fjf1061;

import StandardOutput (Output => Foo);

begin
  WriteLn (Output, 'failed')  { WRONG }
end.
