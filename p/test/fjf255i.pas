program fjf255i; // foo

#define foo // foo
#undef bar // foo

begin
#ifdef foo // Delphi style comment in C style ifdef
  Write ('O');
#else // foo
  WriteLn ('failed');
#endif // foo
#ifdef bar // again
  WriteLn ('failed');
#else // foo
  WriteLn ('K');
#endif // foo
end.
