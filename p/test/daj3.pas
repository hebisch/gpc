{ BUG: modules don't initialize their interface's variables }

program daj3(output);

import globaltypes in 'dajmod3.pas';
       globalvars in 'dajmod3.pas';

begin
 shared_data.prefix:='ABCD';
 if (shared_data.prefix='ABCD') then
   writeln('OK')
 else
   writeln('failed ',shared_data.prefix,'|');
end.
