program daj13(input,output);

var
  f:text;
  s:string(10);

begin
  rewrite(f,'daj13.dat');
  close(f);
  reset(f,'daj13.dat');
  extend(f);
  writeln(f,'OK');
  reset(f);
  readln(f,s);
  writeln(s)
end.
