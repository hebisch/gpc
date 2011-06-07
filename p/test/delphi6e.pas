program delphi6e(Output);
{ FLAG --extended-pascal }
procedure fp(procedure p ()); { WRONG }
  begin
    p
  end;
procedure foo;
  begin
    writeln('failed')
  end;
begin
  fp (foo)
end
.
