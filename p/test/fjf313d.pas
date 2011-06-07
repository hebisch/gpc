{ FLAG --borland-pascal }

program fjf313d;

const foo = 'OK';

{$define foo 'failed'}

begin
{$ifdef foo}
  WriteLn (foo)
{$else}
  WriteLn ('failed')
{$endif}
end.
