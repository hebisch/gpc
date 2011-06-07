{ FLAG --delphi }

program fjf313f;

const foo = 'OK';

{$define foo 'failed'}

begin
{$ifdef foo}
  WriteLn (foo)
{$else}
  WriteLn ('failed')
{$endif}
end.
