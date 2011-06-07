{ Solution: operations on (constant) set constructors
  must be done at compile time. Also more efficient.

  Alternative solution: Allow more general initializers that call
  RTS routines (from the main program initialization code).

  Both done now -- Frank, 20050120 }

program fjf335b;

const
  o : set of char = ['K', 'O', 'X'] - ['X'];

var
  a : char;

begin
  for a := 'Z' downto 'A' do
    if a in o then write (a);
  writeln
end.
