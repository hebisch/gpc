{ FLAG --autobuild --extended-pascal --nested-comments -w }

{ COMPILE-CMD: units.cmp }

program Dialec5 (Output);

import
  GPC;
  {$ifdef HAVE_CRT}
  CRT;
  Turbo3 (LowVideo  => Turbo3_LowVideo,
          HighVideo => Turbo3_HighVideo);  { Turbo3 uses CRT }
  {$endif}
  Dos;
  DosUnix;
  FileUtils;
  {$ifdef HAVE_GMP}
  GMP;
  {$endif}
  GPCUtil;
  {HeapMon;}
  {$ifdef HAVE_INTL}
  Intl;
  {$endif}
  MD5;
  Overlay;
  Pipes;
  {$ifdef i386}
  Ports;
  {$endif}
  Printer;
  {$ifdef HAVE_REGEX}
  RegEx;
  {$endif}
  Strings;
  StringUtils;
  System (MaxLongInt => System_MaxLongInt,
          MemAvail   => System_MemAvail,
          MaxAvail   => System_MaxAvail);  { MemAvail and MaxAvail are in Turbo3 }
  TFDD;
  Trap;
  WinDos (FindFirst => WinDos_FindFirst,
          FindNext  => WinDos_FindNext,
          FindClose => WinDos_FindClose);
  Dialec5u;

begin
  UnredirectOutput;
  WriteLn ('OK')
end.
