program fjf420a;

const foo = 'OK';

{$csdefine FOO 'failed'}

begin
  WriteLn (foo)
end.
