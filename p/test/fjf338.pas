program fjf338;

{ FLAG -Werror }

{$ignore-function-results}

type TString = String(42);

function foo (const s : String) : TString;
begin
  writeln (s);
  foo := ''
end;

begin
  foo ('OK')
end.
