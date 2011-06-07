{ FLAG -Werror }

program fjf470b;

{$W no-underscore}

var
  _foo : Integer;

begin
  _foo := _foo;
  WriteLn ('OK')
end.
