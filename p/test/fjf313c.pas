program fjf313c;

const foo = 'failed';

{$define foo 'OK'}

begin
{$ifdef foo}
  WriteLn (foo)
{$else}
  WriteLn ('failed')
{$endif}
end.
