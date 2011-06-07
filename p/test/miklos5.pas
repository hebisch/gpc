program testit;

var x:real;

begin
 x:=355/113;
 writeln(round(355/113):10);
 writeln(355/113:12:8);
 writeln(round(355/113):10,' ',355/113:12:8);
 writeln(355/113:12:8,' ',round(355/113));
 writeln(round(355/113*100)); writeln(round(355/113*10000));
 writeln(round(x):10);
 writeln(x:12:8);
 writeln(round(x),' ',x:12:8);
 writeln(round(x*100)); writeln(round(x*10000));
end.
