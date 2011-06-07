{ FLAG --no-macros }

program fjf313i;

const foo = 'OK';

{$define foo 'failed'}

begin
  WriteLn (foo)
end.
