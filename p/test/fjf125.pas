program fjf125;

procedure p(s:string);
begin
  s:='Failed'
end;

var s:string(10)='OK';

begin
  p(s);
  writeln(s)
end.
