{ Test of the WinDos unit }

program WinDosTest;

uses GPC, System, WinDos;

var
  s : TSearchRec;
  dt : TDateTime = (0, 0, 0, 0, 0, 0);
  dt2 : TDateTime = (1999, 11, 29, 2, 36, 20);
  t : LongInt = 0;
  t2 : LongInt = $277d148a;

procedure Error (const Msg : String);
begin
  WriteLn (Msg);
  Halt (1)
end;

begin
  if DosError <> 0 then Error ('DosError <> 0');
  FindFirst ('*.*', faDirectory, s);
  if (DosError <> 0) or (CString2String (s.Name) <> DirSelf) then Error ('`' + DirSelf + ''' not found');
  FindNext (s);
  if (DosError <> 0) or (CString2String (s.Name) <> DirParent) then Error ('`' + DirParent + ''' not found');
  PackTime (dt2, t);
  if t <> t then Error ('Error in PackTime');
  UnpackTime (t2, dt);
  if (dt.Year <> dt2.Year) or
     (dt.Month <> dt2.Month) or
     (dt.Day <> dt2.Day) or
     (dt.Hour <> dt2.Hour) or
     (dt.Min <> dt2.Min) or
     (dt.Sec <> dt2.Sec) then Error ('Error in UnpackTime');
  WriteLn ('OK')
end.
