Program IniRec3;

Type
  TOK = record
    O, K: Char;
  end { OK } value ( O: 'O'; K: 'K' );

Var
  OK : TOK;

begin
  with OK do
    writeln ( O, K );
end.
