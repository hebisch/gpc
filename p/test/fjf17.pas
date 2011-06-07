program fjf17;

uses fjf17u;

var
  a:text;
  b:string(10);

begin
  reset (a,'foo.dat');
  readln (a,b);
  writeln (b)
end.
