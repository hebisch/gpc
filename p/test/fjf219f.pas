{ CAUTION: This program may hang! }

program fjf219f;

label bar;

var s:string(100);

procedure baz;
begin
  goto bar
end;

procedure foo;
var f:text;
begin
  rewrite(f);
  writeln(f,'OK');
  reset(f);
  readln(f,s);
  baz
end;

begin
  foo;
bar:
  writeln(s);
end.
