{ COMPILE-CMD: jj5.cmp }

{ FLAG --omit-frame-pointer }

Program JanJaap5;

uses
  JJ5u;

Var
  K: Char value 'K';
  CallOptr: ^Procedure;

Procedure CallO;

begin { CallO }
  O ( 42 );
end { CallO };

begin
  CallOptr:= @CallO;
  CallOptr^;
  writeln ( K );
end.
