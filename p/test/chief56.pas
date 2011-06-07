{ COMPILE-CMD: jj5.cmp }

program Chief56;

TYPE TDllFunc = FUNCTION : Pointer {$ifdef HAVE_STDCALL}
                                   attribute (stdcall)  { Not on all platforms }
                                   {$endif};

begin
  WriteLn ('OK')
end.
