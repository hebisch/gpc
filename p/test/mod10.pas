program Test(output);

import
  ModT10A qualified in 'mod10a.pas';
  ModT10B qualified in 'mod10b.pas';  { `qualified' not yet supported }

begin
  i := -9;  { WRONG }
  writeln('failed');
end.
