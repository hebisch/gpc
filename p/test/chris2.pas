program test;

var
   i : integer;
   f : FILE of integer;
   OK : array [ 1..2 ] of Char = 'OK';

begin
   assign(f,'test.dat');
   rewrite(f);
   for i:=1 to 2
      do write(f,i);
   reset(f);
   while not (eof(f)) do
   begin
      read(f,i);
      write(OK[i]);
   end;
   writeln;
   close(f);
end.
