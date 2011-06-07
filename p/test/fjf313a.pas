program fjf313a;

const foo = 'failed';

{$define foo 'OK'}

begin
  WriteLn (foo)
end.
