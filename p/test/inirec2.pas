Program IniRec2;

Type
  OChar = Char value 'O';
  KChar = Char value 'K';

Var
  OK: record
    O: OChar;
    K: KChar;
  end { OK };

begin
  with OK do
    writeln ( O, K );
end.
