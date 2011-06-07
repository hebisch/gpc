{ BUG: modules (sven14cu.pas) don't initialize their interface's
  variables, so OK.Capacity = 0. }

Program Sven14c;

uses
  Sven14ci in 'sven14cu.pas';

begin
  Init;
  writeln ( OK );
end.
