Program Test;

Const
  sf_File = 1;
  sf_Dir = 2;
  sf_MultiFile = 3;
  sf_MultiDir = 4;

Var
  Flags: record
    StrFlags: Set of Byte;
  end { Flags };

begin
  Flags.StrFlags:= [ sf_File, sf_MultiFile ];
  if Card (Flags.StrFlags * [sf_File, sf_Dir, sf_MultiFile, sf_MultiDir]) > 1 then
    writeln ( 'OK' )
  else
    writeln ( 'failed' )
end.
