program delphi6h(Output);
procedure foo(i: integer); forward;
procedure foo(); { WRONG }
  begin
    writeln('failed');
  end;
begin
  foo(0)
end
.
