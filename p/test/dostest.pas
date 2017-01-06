{ FLAG --autobuild }

{ Test of the Dos unit }

program DosTest;

uses GPC, System, Dos;

var
  s : SearchRec;
  dt : DateTime = (0, 0, 0, 0, 0, 0);
  dt2 : DateTime = (1999, 11, 29, 2, 36, 20);
  t : LongInt = 0;
  t2 : LongInt = $277d148a;
  s1 : String(1024);
  parent_found : Boolean = false;
  self_dir_found : Boolean = false;

procedure Error (const Msg : String);
begin
  WriteLn (Msg);
  Halt (1)
end;

begin
  if DosError <> 0 then Error ('DosError <> 0');
  FindFirst ('*.*', Directory, s);
  while (DosError = 0) and
        (not(self_dir_found) or (not(parent_found))) do begin
      s1 := CString2String (s.Name);
      if s1 = DirSelf then self_dir_found := true;
      if s1 = DirParent then parent_found := true;
      FindNext(s);
  end;
  if DosError <> 0 then Error ('DosError <> 0');
  if not(self_dir_found) then Error ('`' + DirSelf + ''' not found');
  if not(parent_found) then Error ('`' + DirParent + ''' not found');
  PackTime (dt2, t);
  if t <> t2 then Error ('Error in PackTime');
  UnpackTime (t2, dt);
  if (dt.Year <> dt2.Year) or
     (dt.Month <> dt2.Month) or
     (dt.Day <> dt2.Day) or
     (dt.Hour <> dt2.Hour) or
     (dt.Min <> dt2.Min) or
     (dt.Sec <> dt2.Sec) then Error ('Error in UnpackTime');
  Exec ('echo', 'OK');
  if (DosError <> 0) or (DosExitCode <> 0) then Error ('Could not execute `echo OK''')
end.
