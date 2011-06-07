program fjf1065r;

import fjf1066p;
       Uses Only (b);  { This means: import only `b' from `Uses' }
                       { If we allowed specifications as in `import'
                         also in `uses', it could also mean:
                         import ("uses") `b' from `Only'
                         which would make it ambiguous.
                         Therefore, we don't allow such specifications in
                         `uses'. Those who want them can always use `import'
                         instead. }

begin
  if b = 17 then WriteLn ('OK')
end.
