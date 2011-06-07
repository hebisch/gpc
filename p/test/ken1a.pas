Program Ken1a;

Procedure PrintF ( ... ); external name 'printf';

begin
  PrintF ( "%c%c\n", 'O', 'K' );
end.
