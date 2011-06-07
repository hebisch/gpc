program fjf462a;

type
  Str10 = String (10);

function foo = bar : Str10; forward;

function foo = bar : Str10;
begin
  bar := 'OK'
end;

begin
  WriteLn (foo)
end.
