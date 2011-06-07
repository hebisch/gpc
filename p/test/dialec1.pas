Program Dialec1 ( Output );

{ FLAG --classic-pascal -w }

{$extended-pascal }

Var
  O: Char;
  K: Char value 'L';

begin
  {$borland-pascal }
  dec ( K );
  {$gnu-pascal }
  O:= max ( 'O', 'K' );
  writeln ( O, K );
end.
