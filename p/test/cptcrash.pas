Program CPtCrash;

uses
  CPt;

Var
  C: Char value 'A';
  P: CharPtr;
  S: WrkString;

begin
  P:= @C;
  S:= C;
  if S = 'A' then
    write ( 'O' );
  if P^ = 'A' then
    writeln ( 'K' );
end.
