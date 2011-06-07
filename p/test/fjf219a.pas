program fjf219a;

var s:string(100);

procedure foo;
begin
  var f:text;
  rewrite(f);
  writeln(f,'OK');
  reset(f);
  readln(f,s);
end;

begin
  foo;
  writeln(s)
end.
