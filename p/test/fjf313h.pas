{ FLAG --borland-pascal --macros }

program fjf313h;

const foo = 'failed';

{$define foo 'OK'}

begin
  WriteLn (foo)
end.
