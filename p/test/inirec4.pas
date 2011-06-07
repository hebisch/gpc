Program IniRec4;

Type
  OChar = Char value 'O';
  KChar = Char value 'K';

  TOK = record
    O: OChar;
    K: KChar;
  end { OK };

Var
  OK : TOK;

begin
  with OK do
    writeln ( O, K );
end.
