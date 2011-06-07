{ FLAG --nested-comments }

Program Nest14;

#define FOO Write { This is a { nested \
  multiline } comment in a C directive } \
  ('O')
#undef BAR { This is a { nested \
  multiline } comment in a C directive }

begin
#ifdef FOO { This is a { nested \
  multiline } comment in a C ifdef }
  FOO;
#else { This is a { nested \
  multiline } comment in a C else }
  WriteLn ('failed');
#endif { This is a { nested \
  multiline } comment in a C endif }
#ifdef BAR { This is a { nested \
  multiline } comment in a C ifdef }
  WriteLn ('failed');
#else { This is a { nested \
  multiline } comment in a C else }
  WriteLn ('K')
#endif { This is a { nested \
  multiline } comment in a C endif }
end.
