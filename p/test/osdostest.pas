program OSDosTest;

begin
  {$if defined (MSDOS) or defined (_WIN32) or defined (__EMX__)}
  {$ifdef __OS_DOS__}
  WriteLn ('OK')
  {$else}
  WriteLn ('failed')
  {$endif}
  {$else}
  {$ifdef __OS_DOS__}
  WriteLn ('failed')
  {$else}
  WriteLn ('OK')
  {$endif}
  {$endif}
end.
