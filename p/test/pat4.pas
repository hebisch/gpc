Program Pat4;

Const
  SIG_KO         = 0;
  SIG_OK         = 1;

type
  S20C = String ( 20 );
  Sig_Type = array[0..SIG_OK] of S20C;

{ FIXED: Could not initialize arrays of Strings }

var
  Signal_Test : S20C value 'SIGFOO';
  Signal_Type : Sig_Type value ('KO','OK');

begin
  writeln ( Signal_Type [ SIG_OK ] );
end.
