{ close files before gotos out of their scope (fjf219[ef].pas) }

{ CAUTION: This program may hang! }

program fjf219e;

label bar;

var s:string(100);

procedure foo;
var f:text;
begin
  rewrite(f);
  writeln(f,'OK');
  reset(f);
  readln(f,s);
  goto bar
end;

begin
  foo;
bar:
  writeln(s);
end.
