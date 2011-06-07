program delphi6g(Output);
procedure fp(procedure p);
  begin
    p
  end;
procedure foo;
  begin
    writeln('failed');
  end;
begin
  fp(foo()) { WRONG }
end
.
