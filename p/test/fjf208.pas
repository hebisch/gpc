program fjf208;

var foo:boolean=false;

function q:cstring;
begin
  if foo then begin writeln('Failed'); halt(1) end;
  foo:=true;
  q:='OK'
end;

begin
  writeln(cstring2string(q))
end.
