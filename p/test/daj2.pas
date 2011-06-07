program daj2;

import progtypes in 'dajmod2.pas';
       globalvars in 'dajmod2.pas';

begin
 pgmtype:=prog_press;
 if (pgmtype=prog_press) then
   writeln('OK')
 else
   writeln('failed');
end.
