{
  That's not a test for Y2K problems because GPC does not have such
  problems. ;-b Instead it tests an obscure "feature" of GPC's Dos
  unit it a "Y2K like" situation.
}

{ FLAG --autobuild -D__BP_UNPORTABLE_ROUTINES__ }

program Y2K; {-;-}

uses GPC, Dos;

var
  h, m, s, s100, y, mo, d, dow, a1, a2, t1, t2, t3 : Word;

begin
  GetTime (h, m, s, s100);
  GetDate (y, mo, d, dow);
  SetTime (23, 59, 59, 50);
  SetDate (1999, 12, 31);
  GetDate (a1, t1, t2, t3);
  Sleep (2);
  GetDate (a2, t1, t2, t3);
  SetTime (h, m, s + 1, s100);
  SetDate (y, mo, d);
  if (a1 = 1999) and (a2 = 2000) then WriteLn ('OK') else WriteLn ('failed ', a1, ' ', a2)
end.
