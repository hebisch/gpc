{ FLAG --nested-comments }

Program Nest8;

#define FOO WriteLn { This is a { nested } comment in a C directive } ('OK')

begin
  FOO
end.
