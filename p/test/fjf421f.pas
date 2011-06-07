program fjf421f;

const foo = 'failed';

{$cidefine foo 'OK'}

begin
  WriteLn (FOO)
end.
