program init3e;
type tvr = record case boolean of
                    false :(f : integer);
                    true :(case boolean of
                       false :(tf : integer);
                       true :(tt : record c : char end);
                  )
           end;
var v : tvr value (tt:('a'));
begin
  if v.tt.c = 'a' then writeln('OK')
end
.
