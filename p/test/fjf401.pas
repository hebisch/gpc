{ Works only if the executable is called a.* }

program fjf401;

uses GPC;

var
  Dir : String (256);  {@@ avoid stack overflow on DJGPP because of many string concatenations}
  f1, f2, f3, f4 : Text;
  c : Integer;

procedure Test (const a, b : String);
begin
  Inc (c);
  if a <> b then
    begin
      WriteLn ('failed ', c, ': ', a, ' (expected: ', b, ')');
      if OSDosFlag then
        begin
          {$I-}
          Assign (f1, Dir + 'a.ini'); Erase (f1); InOutRes := 0;
          Assign (f2, Dir + 'fjffoo.ini'); Erase (f2); InOutRes := 0;
          Assign (f3, Dir + 'a.cfg'); Erase (f3); InOutRes := 0;
          Assign (f4, Dir + 'fjffoo.cfg'); Erase (f4); InOutRes := 0
          {$I+}
        end;
      Halt
    end
end;

begin
  c := 0;
  if OSDosFlag then
    begin
      Dir := DirFromPath (ExecutablePath);
      if not FileNamesCaseSensitive then LoCaseString (Dir);
      {$ifdef __GPC__}
      {$I-}
      Assign (f1, Dir + 'a.ini'); Erase (f1); InOutRes := 0;
      Assign (f2, Dir + 'fjffoo.ini'); Erase (f2); InOutRes := 0;
      Assign (f3, Dir + 'a.cfg'); Erase (f3); InOutRes := 0;
      Assign (f4, Dir + 'fjffoo.cfg'); Erase (f4); InOutRes := 0;
      {$I+}
      UnSetEnv ('DJDIR');
      UnSetEnv ('HOME');
      {$endif}
      Test (ConfigFileName ('', '', True), Dir + 'a.ini');
      Test (ConfigFileName ('', 'fjffoo', True), Dir + 'fjffoo.ini');
      Test (ConfigFileName ('/usr/local', '', True), Dir + 'a.ini');
      Test (ConfigFileName ('/usr/local', 'fjffoo', True), Dir + 'fjffoo.ini');
      Test (ConfigFileName ('', '', False), Dir + 'a.cfg');
      Test (ConfigFileName ('', 'fjffoo', False), Dir + 'fjffoo.cfg');
      Test (ConfigFileName ('/usr/local', '', False), Dir + 'a.cfg');
      Test (ConfigFileName ('/usr/local', 'fjffoo', False), Dir + 'fjffoo.cfg');
      Test (DataDirectoryName ('', ''), Dir);
      Test (DataDirectoryName ('', 'fjffoo'), Dir);
      Test (DataDirectoryName ('/usr/local', ''), Dir);
      Test (DataDirectoryName ('/usr/local', 'fjffoo'), Dir);
      {$ifdef __GPC__}
      SetEnv ('DJDIR', 'c:\djgpp');
      SetEnv ('HOME', 'c:\home\me');
      {$ifdef __GO32__}
      Test (ConfigFileName ('', '', True), 'c:\djgpp\etc\a.ini');
      Test (ConfigFileName ('', 'fjffoo', True), 'c:\djgpp\etc\fjffoo.ini');
      Test (ConfigFileName ('/usr/local', '', True), 'c:\djgpp\etc\a.ini');
      Test (ConfigFileName ('/usr/local', 'fjffoo', True), 'c:\djgpp\etc\fjffoo.ini');
      {$else}
      Test (ConfigFileName ('', '', True), 'c:\home\me\a.ini');
      Test (ConfigFileName ('', 'fjffoo', True), 'c:\home\me\fjffoo.ini');
      Test (ConfigFileName ('/usr/local', '', True), 'c:\home\me\a.ini');
      Test (ConfigFileName ('/usr/local', 'fjffoo', True), 'c:\home\me\fjffoo.ini');
      {$endif}
      Test (ConfigFileName ('', '', False), 'c:\home\me\a.cfg');
      Test (ConfigFileName ('', 'fjffoo', False), 'c:\home\me\fjffoo.cfg');
      Test (ConfigFileName ('/usr/local', '', False), 'c:\home\me\a.cfg');
      Test (ConfigFileName ('/usr/local', 'fjffoo', False), 'c:\home\me\fjffoo.cfg');
      {$ifndef __GO32__}
      UnSetEnv ('HOME');
      {$endif}
      Test (DataDirectoryName ('', ''), Dir);
      Test (DataDirectoryName ('', 'fjffoo'), Dir);
      Test (DataDirectoryName ('/usr/local', ''), Dir);
      Test (DataDirectoryName ('/usr/local', 'fjffoo'), Dir);
      Rewrite (f1); Close (f1);
      Rewrite (f2); Close (f2);
      Rewrite (f3); Close (f3);
      Rewrite (f4); Close (f4);
      SetEnv ('HOME', 'c:\home\me');
      Test (ConfigFileName ('', '', True), Dir + 'a.ini');
      Test (ConfigFileName ('', 'fjffoo', True), Dir + 'fjffoo.ini');
      Test (ConfigFileName ('/usr/local', '', True), Dir + 'a.ini');
      Test (ConfigFileName ('/usr/local', 'fjffoo', True), Dir + 'fjffoo.ini');
      Test (ConfigFileName ('', '', False), Dir + 'a.cfg');
      Test (ConfigFileName ('', 'fjffoo', False), Dir + 'fjffoo.cfg');
      Test (ConfigFileName ('/usr/local', '', False), Dir + 'a.cfg');
      Test (ConfigFileName ('/usr/local', 'fjffoo', False), Dir + 'fjffoo.cfg');
      {$ifndef __GO32__}
      UnSetEnv ('HOME');
      {$endif}
      Test (DataDirectoryName ('', ''), Dir);
      Test (DataDirectoryName ('', 'fjffoo'), Dir);
      Test (DataDirectoryName ('/usr/local', ''), Dir);
      Test (DataDirectoryName ('/usr/local', 'fjffoo'), Dir);
      {$I-}
      Erase (f1); InOutRes := 0;
      Erase (f2); InOutRes := 0;
      Erase (f3); InOutRes := 0;
      Erase (f4); InOutRes := 0;
      {$I+}
      {$endif}
    end
  else
    begin
      {$ifdef __GPC__}
      SetEnv ('HOME', '/home/me/');
      {$endif}
      Test (ConfigFileName ('', '', True), '/etc/a.conf');
      Test (ConfigFileName ('', 'fjffoo', True), '/etc/fjffoo.conf');
      Test (ConfigFileName ('/usr/local', '', True), '/usr/local/etc/a.conf');
      Test (ConfigFileName ('/usr/local', 'fjffoo', True), '/usr/local/etc/fjffoo.conf');
      Test (ConfigFileName ('', '', False), '/home/me/.a');
      Test (ConfigFileName ('', 'fjffoo', False), '/home/me/.fjffoo');
      Test (ConfigFileName ('/usr/local', '', False), '/home/me/.a');
      Test (ConfigFileName ('/usr/local', 'fjffoo', False), '/home/me/.fjffoo');
      Test (DataDirectoryName ('', ''), '/usr/share/a/');
      Test (DataDirectoryName ('', 'fjffoo'), '/usr/share/fjffoo/');
      Test (DataDirectoryName ('/usr/local', ''), '/usr/local/share/a/');
      Test (DataDirectoryName ('/usr/local', 'fjffoo'), '/usr/local/share/fjffoo/')
    end;
  WriteLn ('OK')
end.
