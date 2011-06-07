program fjf123;

procedure p(var s:String);
begin
  writeln(s)
end;

var led:string(3)='led';

begin
  p('Fai'+led) { WRONG }
end.
