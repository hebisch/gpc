{ COMPILE-CMD: gettext2.cmp }

{ DJGPP: When called gettext2test (and therefore usually run after many other
  tests), the following error appears (at least under DosEmu):

  TEST	gette~w8.pas:	OK
  c:/djgpp/bin/rm: tmplocale: Permission denied (EACCES)

  For all I know, that's no GPC problem, so let's work around it.
  Using a file name starting with `a' will (usually) cause it
  to be run earlier (cf. afileutilstest) ... -- Frank }

program GetText2Test;

uses GPC, Intl;

var
  s: TString;
  OK: Boolean = True;
  n: Integer = 0;

procedure Check (const s, e: String);
begin
  Inc (n);
  if s <> e then
    begin
      WriteLn ('failed ', n, ': ', s, ' (', e, ')');
      OK := False
    end
end;

begin
{$ifdef __GO32__}
  s := SetLocale (LC_MESSAGES, '');
  if s <> 'C' then
    begin
      WriteLn ('SKIPPED: could not set locale `''');
{$else}
  s := SetLocale (LC_MESSAGES, 'de_DE');
  if s <> 'de_DE' then
    begin
      WriteLn ('SKIPPED: could not set locale `de_DE''');
{$endif}
      Halt
    end;
  Check (BindTextDomain ('gettext2test', 'tmplocale'), 'tmplocale');
  Check (TextDomain ('gettext2test'), 'gettext2test');
  Check (GetText ('foobar'), 'bazqux');
  if OK then WriteLn ('OK')
end.
