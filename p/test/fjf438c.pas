program fjf438c;

uses GPC;

var
  f:text;
  s:String(10);

begin
  FileMode:=10;
  extend(f);
  writeln(f,'OK');
  reset(f);
  readln(f,s);
  writeln(s)
end.
