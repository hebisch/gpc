program fjf244;

{ FLAG -Werror }

type t=^t;

var p:t;

begin
  new(p);
  p^:=p;
  if p=p^ then writeln('OK') else writeln('failed')
end.
