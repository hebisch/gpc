program test(input, output);

type
  string5 = packed array[1..5] of char;

var
  inname : string5;
  i : Integer;

begin
        readln(inname);
        i := 5;
        while inname [i] = ' ' do Dec (i);
        writeln(inname : i);
end.
