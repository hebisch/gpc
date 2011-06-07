{ FLAG --autobuild --borland-pascal }

{ COMPILE-CMD: units.cmp }

program Dialec7;

{$ifdef HAVE_CRT}
{ WinCRT can't be used together with CRT, therefore this test is separate from dialec3.pas }
uses WinCRT;
{$endif}

begin
  Assign (Output, '');
  Rewrite (Output);
  WriteLn ('OK')
end.
