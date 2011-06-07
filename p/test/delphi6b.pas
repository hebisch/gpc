program delphi6b(Output);
{ FLAG --extended-pascal }
procedure foo;
begin
   Writeln ('failed');
end;
begin
   foo (); { WRONG }
end.
