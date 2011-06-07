{ Test of the GPC unit. Well, there's a lot more to test, and we
  probably shouldn't do it all in one single test program, but there
  are other tests which test other parts of the GPC unit... }

program GPCTest;

uses GPC;

var
  d : DirPtr;
  s : TString;
  r : Real;
  ts : TimeStamp;
  { Note: libc's time_t may be unsigned, so dates before
    1970-01-01 00:00:00 UTC may not be handled correctly. Depending
    on the time zone, we may have to start at 1970-01-02 to be safe
    (and subtract 86400, see below). }
  ts0 : TimeStamp = (True, True, 1970, 1, 2, 0, 0, 0, 0, 0);
  ts2 : TimeStamp = (True, True, 1999, 11, 29, 1, 2, 19, 48, 0);
  ut : UnixTimeType;
  ut2 : UnixTimeType = 943841988;
  TZ : UnixTimeType;

procedure Error (const Msg : String);
begin
  WriteLn ('Error in ', Msg);
  Halt (1)
end;

function IsDST (Time: UnixTimeType) = Res: Boolean;
begin
  UnixTimeToTime (Time, null, null, null, null, null, null, null, Res, null, null)
end;

begin
  if (Pos ('foo', 'FoofooFoofoofooFoofooFoo')) <> 4 then Error ('Pos');
  if (LastPos ('foo', 'FoofooFoofoofooFoofooFoo')) <> 19 then Error ('LastPos');
  if (PosCase ('foo', 'FoofooFoofoofooFoofooFoo')) <> 1 then Error ('PosCase');
  if (LastPosCase ('foo', 'FoofooFoofoofooFoofooFoo')) <> 22 then Error ('LastPosCase');
  if (CharPos (['o'], 'FoofooFoofoofooFoofooFoo')) <> 2 then Error ('CharPos');
  if (LastCharPos (['o'], 'FoofooFoofoofooFoofooFoo')) <> 24 then Error ('LastCharPos');
  if (PosFrom ('foo', 'FoofooFoofoofooFoofooFoo', 5)) <> 10 then Error ('PosFrom');
  if (LastPosTill ('foo', 'FoofooFoofoofooFoofooFoo', 20)) <> 13 then Error ('LastPosTill');
  if (PosFromCase ('foo', 'FoofooFoofoofooFoofooFoo', 5)) <> 7 then Error ('PosFromCase');
  if (LastPosTillCase ('foo', 'FoofooFoofoofooFoofooFoo', 18)) <> 16 then Error ('LastPosTillCase');
  if (CharPosFrom (['o'], 'FoofooFoofoofooFoofooFoo', 9)) <> 9 then Error ('CharPosFrom');
  if (LastCharPosTill (['o'], 'FoofooFoofoofooFoofooFoo', 16)) <> 15 then Error ('LastCharPosTill');
  if IsPrefix ('foo', 'Food') then Error ('IsPrefix #1');
  if not IsPrefix ('foo', 'foodFood') then Error ('IsPrefix #2');
  if IsPrefixCase ('foo', 'barFood') then Error ('IsPrefixCase #1');
  if not IsPrefixCase ('foo', 'Food') then Error ('IsPrefixCase #2');
  if IsSuffix ('foo', 'xFoo') then Error ('IsSuffix #1');
  if not IsSuffix ('foo', 'xFoofoo') then Error ('IsSuffix #2');
  if IsSuffixCase ('foo', 'barFood') then Error ('IsSuffixCase #1');
  if not IsSuffixCase ('foo', 'barFoo') then Error ('IsSuffixCase #2');
  if GetDayOfWeek (29, 11, 1999) <> 1 then Error ('GetDayOfWeek');
  ut := TimeStampToUnixTime (ts0);
  if IsDST (ut) then Dec (ut, 3600);
  TZ := -(ut - 86400);
  if TZ >= 0 then
    TZ := (TZ + 300) div 900 * 900
  else
    TZ := (TZ - 300) div 900 * 900;
  if (TZ < - 12 * 60 * 60) or (TZ > 12 * 60 * 60) then
    WriteLn ('warning: strange time zone ', TZ / 3600 : 0 : 2);
  UnixTimeToTimeStamp (ut2 - TZ - 3600 * Ord (IsDST (ut2 - TZ)), ts);
  if not ts.DateValid or
     not ts.TimeValid or
     (ts.Year <> ts2.Year) or
     (ts.Month <> ts2.Month) or
     (ts.Day <> ts2.Day) or
     (ts.DayOfWeek <> ts2.DayOfWeek) or
     (ts.Hour <> ts2.Hour) or
     (ts.Minute <> ts2.Minute) or
     (ts.Second <> ts2.Second) or
     (ts.MicroSecond <> ts2.MicroSecond) then
    begin
      WriteLn (TimeStampToUnixTime (ts0));
      WriteLn (TZ);
      WriteLn (ut2);
      WriteLn (ts.DateValid);
      WriteLn (ts.TimeValid);
      WriteLn (ts.Year, ' ', ts2.Year);
      WriteLn (ts.Month, ' ', ts2.Month);
      WriteLn (ts.Day, ' ', ts2.Day);
      WriteLn (ts.DayOfWeek, ' ', ts2.DayOfWeek);
      WriteLn (ts.Hour, ' ', ts2.Hour);
      WriteLn (ts.Minute, ' ', ts2.Minute);
      WriteLn (ts.Second, ' ', ts2.Second);
      WriteLn (ts.MicroSecond, ' ', ts2.MicroSecond);
      Error ('UnixTimeToTimeStamp')
    end;
  ut := TimeStampToUnixTime (ts2);
  if ut - 3600 * Ord (IsDST (ut)) <> ut2 - TZ then Error ('TimeStampToUnixTime');
  if IsLeapYear (1999) then Error ('IsLeapYear #1');
  if not IsLeapYear (1996) then Error ('IsLeapYear #2');
  if IsLeapYear (1900) then Error ('IsLeapYear #3');
  if not IsLeapYear (2000) then Error ('IsLeapYear #4');  { This test should rather be run on many humans... ;-}
  if RemoveDirSeparator (FExpand (DirSelf) + DirSeparator + DirSeparator + DirSeparator + DirSeparator)
    <> FExpand (DirSelf) then Error ('RemoveDirSeparator');
  if AddDirSeparator (DirSelf) <> DirSelf + DirSeparator then Error ('AddDirSeparator #1');
  if AddDirSeparator (DirSelf + DirSeparator) <> DirSelf + DirSeparator then Error ('AddDirSeparator #1');
  if AddDirSeparator ('nonexisting-directory') <> 'nonexisting-directory' then Error ('AddDirSeparator #3');
  if ForceAddDirSeparator (DirSelf) <> DirSelf + DirSeparator then Error ('ForceAddDirSeparator #1');
  if ForceAddDirSeparator (DirSelf + DirSeparator) <> DirSelf + DirSeparator then Error ('ForceAddDirSeparator #1');
  if ForceAddDirSeparator ('nonexisting-directory') <> 'nonexisting-directory' + DirSeparator then Error ('ForceAddDirSeparator #3');
  if GetCurrentDirectory <> FExpand (DirSelf) then Error ('GetCurrentDirectory');
  if GetTempFileName ={sic!} GetTempFileName then Error ('GetTempFileName');
  s := FExpand (ParamStr (0));
  if DirFromPath (s) + NameFromPath (s) + ExtFromPath (s) <> s then Error ('DirFromPath/NameFromPath/ExtFromPath');
  if DirFromPath (s) + NameExtFromPath (s) <> s then Error ('DirFromPath/NameExtFromPath');
  d := OpenDir (DirSelf);
  if d = nil then Error ('OpenDir');
  s := ReadDir (d);
  if (s <> DirSelf) then Error ('ReadDir #1');
  s := ReadDir (d);
  if (s <> DirParent) then Error ('ReadDir #1');
  CloseDir (d);
  SeedRandom (42);
  r := Random;
  SeedRandom (42);
  if r <> Random then Error ('SeedRandom');
  WriteLn ('OK')
end.
