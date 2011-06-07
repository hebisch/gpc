program fjf234b;

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

{$W-,borland-pascal}

begin
  with foo do writeln(a,b)
end.
