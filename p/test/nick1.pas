{ BUG: modules don't initialize their interface's variables }

program my_main (input,output);
import nick1m1;
       nick1m2;

Var
   another_str : mystr := '7654321';
   another_int : integer := 361;

begin
   sSet ('0123456');
   writeln ('1. my_main another_str:',another_str,'.');
   another_str := sGet;
   writeln ('2. my_main another_str:',another_str,'.');

   iSet (19);
   writeln ('1. my_main another_int:',another_int,'.');
   another_int := iGet;
   writeln ('2. my_main another_int:',another_int,'.');

end.
