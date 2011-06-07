{ COMPILE-CMD: intl.cmp }

program GetTextTest;

uses GPC, Intl;

var
  LocaleDir, s: TString;

begin
  LocaleDir := {$ifdef __GO32__} GetEnv ('$DJDIR') + '/share/locale' {$else} '/usr/share/locale' {$endif};
  s := SetLocale (LC_MESSAGES, 'de_DE');
  s := BindTextDomain ('gettext', LocaleDir);
  s := TextDomain ('gettext');
  s := GetText (" done.\n");
  if (s = " done.\n") or (s = " fertig.\n") then WriteLn ('OK') else WriteLn ('failed ', s)
end.
