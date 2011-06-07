{$no-macros}

program fjf313j;

const foo = 'OK';

{$define foo 'failed'}

begin
  WriteLn (foo)
end.
