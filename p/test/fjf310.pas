program fjf310;

{ FLAG -Wall -Werror }

type e = (a, b);

var v : e = a;

begin
  case v of
    a : writeln ('OK')
  end
end.
