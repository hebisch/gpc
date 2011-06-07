{ FLAG --borland-pascal }

program fjf313b;

const foo = 'OK';

{$define foo 'failed'}

begin
  WriteLn (foo)
end.
