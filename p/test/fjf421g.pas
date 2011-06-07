{ FLAG -Wno-identifier-case }

program fjf421g;

const foo = 'OK';

#define foo 'failed'

begin
  WriteLn (FOO)
end.
