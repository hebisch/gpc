program fjf70a;
type t(a:integer)=record
                 foo: array[1..a] of char;
               end { t };

var
  OK: t ( 2 );

procedure p(var v:t);
begin
 with v do writeln(foo)
end;

begin
  with OK do
    foo:= 'OK';
  p ( OK );
end.
