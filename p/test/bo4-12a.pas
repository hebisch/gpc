Program BO4_12a;

uses
  BO4_12u in 'bo4-12u.pas';

Type
  String2 = String ( 2 );

  pMenu = ^tMenu;

  tMenu = object ( tView )
    Constructor Init;
    Function Current: String2; virtual;
  end { tMenu };

Var
  Menu: tMenu;

Constructor tMenu.Init;

begin { tMenu.Init }
end { tMenu.Init };

Function tMenu.Current: String2;

begin { tMenu.Current }
  Current:= 'OK';
end { tMenu.Current };

begin
  Menu.Init;
  writeln ( Menu.Current );
end.
