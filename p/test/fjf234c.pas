program fjf234c;

{ FLAG -Werror }

var i:integer;

function foo=bar:integer;
begin
  val('1e',i,bar)
end;

begin
  if foo=2 then writeln('OK') else writeln('failed')
end.
