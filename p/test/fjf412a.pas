program fjf412a;

begin
{$define foo}
{$ifdef foo}
  WriteLn ('OK')
{$else foo}
  WriteLn ('failed')
{$endif foo}
end.
