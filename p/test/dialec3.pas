{ FLAG --autobuild --borland-pascal }

{ COMPILE-CMD: units.cmp }

program Dialec3;

uses
  GPC,
  {$ifdef HAVE_CRT}
  CRT,
  Turbo3,  { uses CRT }
  {$endif}
  Dos,
  DosUnix,
  FileUtils,
  {$ifdef HAVE_GMP}
  GMP,
  {$endif}
  GPCUtil,
  {HeapMon,}
  {$ifdef HAVE_INTL}
  Intl,
  {$endif}
  MD5,
  Overlay,
  Pipes,
  {$ifdef i386}
  Ports,
  {$endif}
  Printer,
  {$ifdef HAVE_REGEX}
  RegEx,
  {$endif}
  Strings,
  StringUtils,
  System,
  TFDD,
  Trap,
  WinDos;

begin
  Assign (Output, '');
  Rewrite (Output);
  WriteLn ('OK')
end.
