{ CAUTION: This program may hang! }

program fjf219h;

label bar;

var
  s:string(100);
  g:text;

procedure baz;
begin
  goto bar
end;

procedure foo;
var f:text;
begin
  rewrite(f,'test.dat');
  writeln(f,'OK');
  baz
end;

begin
  foo;
bar:
  reset(g,'test.dat');
  readln(g,s);
  writeln(s);
end.
