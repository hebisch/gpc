{ FLAG --nested-comments }

Program Nest11;

#define FOO WriteLn (* This is a (* nested \
  multiline *) comment in a Pascal directive *) ('OK')

begin
  FOO
end.
