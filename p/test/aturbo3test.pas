{ COMPILE-CMD: units.cmp }

{ Test of the Turbo3 unit }

program Turbo3Test;

{$ifdef HAVE_CRT}
uses CRT, Turbo3;

begin
  Close (Output);
  Assign (Output, '');
  Rewrite (Output, '');
  if NormAttr = Yellow + $10 * Black then WriteLn ('OK') else WriteLn ('Failed')
end.
{$else}
{ A `SKIPPED' message is already produced by CRTTest. No need for another one. }
begin
  WriteLn ('OK')
end.
{$endif}
