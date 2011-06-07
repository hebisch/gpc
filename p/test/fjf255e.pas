program fjf255e; // foo

begin
#if 1 // Delphi style comment in C style directive
  Write ('O');
#else // foo
  WriteLn ('failed');
#endif // foo
#if 0 // again
  WriteLn ('failed');
#else // foo
  WriteLn ('K');
#endif // foo
end.
