Program IniRec1;

Var
  OK: record
    O, K: Char;
  end { OK } value ( O: 'O'; K: 'K' );

begin
  with OK do
    writeln ( O, K );
end.
