{ close files before gotos out of their scope (fjf219[ef].pas) }

{ CAUTION: This program may hang! }

program fjf219g;

label bar;

var
  s:string(100);
  g:text;

procedure foo;
var f:text;
begin
  rewrite(f,'test.dat');
  writeln(f,'OK');
  goto bar
end;

begin
  foo;
bar:
  reset(g,'test.dat');
  readln(g,s);
  writeln(s);
end.
