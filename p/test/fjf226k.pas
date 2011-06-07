{ BUG: fjf226 (tm;-) }

program fjf226k;

{$B-}

type
  pfoo = ^tfoo;
  tfoo = object
    constructor bar
  end;

constructor tfoo.bar;
begin
  writeln ('failed (foo)');
  halt (1)
end;

begin
  if false and (new (pfoo, bar) <> nil)
    then writeln ('failed (bar)')
    else writeln ('OK')
end.
