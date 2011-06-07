{ FLAG -Wall -W -Werror -Wswitch }

program fjf706b;

type
  e = (b, c, d);

var
  a: e = c;

begin
  case a of
    c: WriteLn ('OK');
    else WriteLn ('failed')
  end
end.
