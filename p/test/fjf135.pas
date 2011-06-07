program fjf135;

procedure p(s:String);
var a:integer;
begin
  ReadStr(s,a);
  write(chr(a))
end;

var s:String(10);

begin
  writestr(s,ord('O'));
  p(s);
  writeln('K')
end.
