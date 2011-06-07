program fjf438b;

uses GPC;

var
  f:text;
  s:String(10);

begin
  FileMode:=6;
  rewrite(f);
  writeln(f,'OK');
  reset(f);
  readln(f,s);
  writeln(s)
end.
