{ Precedence of `@' vs. `^' }

program fjf983;

var
  i: Integer;

begin
  i := @i^  { WRONG }
end.
