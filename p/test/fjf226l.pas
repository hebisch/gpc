{ BUG: fjf226 (tm;-) }

program fjf226l;

{$B-}

type tstring = string(10);

function s : tstring;
begin
  s := 'foo';
  writeln ('failed (foo)');
  halt (1)
end;

begin
  if false and (s + 'bar' <> '')
    then writeln ('failed (foobar)')
    else writeln ('OK')
end.
