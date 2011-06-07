{ FLAG -Wno-identifier-case }

program fjf421e;

const foo = 'OK';

{$csdefine foo 'failed'}

begin
  WriteLn (FOO)
end.
