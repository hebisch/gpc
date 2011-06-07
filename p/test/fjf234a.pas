program fjf234a;

{ FLAG -Werror }

type x=record a,b:char end;

procedure bar(var a:char;b:char);
begin
  a:=b
end;

function foo=q:x;
begin
  bar(q.a,'O');bar(q.b,'K')
end;

var y:x;

begin
  y:=foo;
  with y do writeln(a,b)
end.
