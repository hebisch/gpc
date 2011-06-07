Unit BO4_12u;

Interface

uses
  BO4_12v in 'bo4-12v.pas';

Type
  pView = ^tView;
  pGroup = ^tGroup;

  tView = object ( tObject )
  end { tView };

  tGroup = object ( tView )
    Current: pView;
  end { tGroup };

Implementation

end.
