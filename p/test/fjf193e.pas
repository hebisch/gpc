{ solution: fkind_BINDABLE }

program fjf193e(Output);

procedure Check;
begin
  if IOResult <> 0 then WriteLn ('OK') else WriteLn ('failed')
end;

{$I-}
{$extended-pascal}
var foo: text;
procedure p(var a:text);
begin
  Unbind (a);  { a is not declared bindable --> runtime error }
end;

begin
  p(foo);
  Check
end.
