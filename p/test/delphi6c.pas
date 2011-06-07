program delphi6c(Output);
{ FLAG --extended-pascal }
procedure foo (); { WRONG }
begin
   Writeln ('failed');
end;
begin
   foo
end.
