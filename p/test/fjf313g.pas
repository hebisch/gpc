{ FLAG --borland-pascal }

{$macros}

program fjf313g;

const foo = 'failed';

{$define foo 'OK'}

begin
  WriteLn (foo)
end.
