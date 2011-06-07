{ FLAG --delphi }

program fjf313e;

const foo = 'OK';

{$define foo 'failed'}

begin
  WriteLn (foo)
end.
