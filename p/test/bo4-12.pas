Program BO4_12;

uses
  BO4_12u in 'bo4-12u.pas';

Type
  pMenu = ^tMenu;

  tMenu = object ( tView )
    Current: ^String;
  end { tMenu };

Var
  Menu: tMenu;

begin
  Menu.Current:= @'OK';
  writeln ( Menu.Current^ );
end.
