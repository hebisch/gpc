{ COMPILE-CMD: fjf412b.cmp }

{ FLAG --pedantic-errors }

program fjf412b;

begin
{$define foo}
{$ifdef foo}
  WriteLn ('OK')
{$else foo}
  WriteLn ('failed')
{$endif foo}
end.
