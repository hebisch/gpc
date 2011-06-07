{ FLAG -Wall -W -Werror -Wswitch }

program fjf706a;

type
  e = (b, c, d);

var
  a: e = c;

begin
  case a of
    b: WriteLn ('failed 1');
    c: WriteLn ('OK');
    d: WriteLn ('failed 2');
    else WriteLn ('failed 3')
  end
end.
