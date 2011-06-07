{ FLAG --nested-comments }

Program Nest10;

#define FOO WriteLn { This is a { nested \
  multiline } comment in a C directive } ('OK')

begin
  FOO
end.
