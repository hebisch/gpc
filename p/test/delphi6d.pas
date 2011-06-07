program delphi6d(Output);
{ FLAG --extended-pascal }
procedure foo (); { WRONG }
begin
   Writeln ('failed');
end;
begin
   foo (); { WRONG }
end.
