program test(input, output);
var
   testfile:  text;
   i, j, repetitions:  integer;
begin
   rewrite(testfile);
   readln(repetitions);
   for i:=1 to repetitions do
      writeln(testfile, i);
   reset(testfile);
   for i:=1 to repetitions do begin
      read(testfile, j);
      if j <> i then
         writeln('read/write error');
      end;
   readln(testfile);
   if not eof(testfile) then
      writeln('eof not reached')
   else
     writeln('OK')
end.
