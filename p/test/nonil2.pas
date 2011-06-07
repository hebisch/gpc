Program NoNil2;

Var
  p: Pointer value Nil;

begin
  if p = 0 then  { WRONG }
    writeln ('failed')
end.
