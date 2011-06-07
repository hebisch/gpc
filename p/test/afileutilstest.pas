{ Test of the FileUtils unit }

{ DosEmu gets problems when this is run in a longer directory.
  For all I know, that's no GPC problem, so let's work around it.
  Using a file name starting with `a' will (usually) cause it
  to be run in a not so full directory ... -- Frank }

program FileUtilsTest;

uses GPC, FileUtils;

const
  TestName = 'f_u_test.dat'; { must fit into 8+3 chars }

var
  Called : Boolean = False;
  f : Text;

procedure DoOutput (const s : String);
begin
  if Called then
    begin
      WriteLn ('failed: `DoOutput'' called twice');
      Halt
    end;
  if s <> DirSelf + DirSeparator + TestName then
    begin
      WriteLn ('failed `', s, '''');
      Halt
    end;
  Called := True
end;

begin
  Rewrite (f, TestName);
  Close (f);
  FindFiles (DirSelf, TestName, False, DoOutput, DoOutput);
  Erase (f);
  if not Called then
    WriteLn ('failed: `DoOutput'' not called')
  else
    WriteLn ('OK')
end.
