{ solution: fkind_BINDABLE }

program fjf193c(Output);

procedure Check;
begin
  if IOResult <> 0 then WriteLn ('OK') else WriteLn ('failed')
end;

{$I-}
{$extended-pascal}
var foo: text;
procedure p(var a:text);
var b: BindingType;
begin
  b:= binding(a);  { a is not declared bindable --> runtime error }
end;

begin
  p(foo);
  Check
end.
