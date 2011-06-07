Program Objects;


{ Bug fixed: objects only worked in units, not in programs. }


Type
  ParentPtr = ^ParentObj;
  ChildPtr = ^ChildObj;


ParentObj = object
  Constructor Init;
  Destructor Fini;
  Procedure O;
  c, d: Char;  { GNU extension: mixing of fields and methods }
  Procedure K; virtual;
end { ParentObj };


ChildObj = object ( ParentObj )
  { Bug fixed: no dummy variable needed here. }
  Procedure O;
  Procedure K; virtual;
end { ChildObj };


Var
  MyObject: ParentPtr;


Constructor ParentObj.Init;

begin { ParentObj.Init }
  c:= 'K';
end { ParentObj.Init };


Destructor ParentObj.Fini;

begin { ParentObj.Fini }
  c:= chr ( 0 );
end { ParentObj.Fini };


Procedure ParentObj.O;

begin { ParentObj.O }
  write ( 'O' );
end { ParentObj.O };


Procedure ParentObj.K;

begin { ParentObj.K }
  d := 'y';
end { ParentObj.K };


Procedure ChildObj.O;

begin { ChildObj.O }
  write ( 'x' );
end { ChildObj.O };


Procedure ChildObj.K;

begin { ChildObj.K }
  inherited K;
  writeln ( succ ( d, ord ( c ) - ord ( 'y' ) ) );
end { ChildObj.K };


begin
  MyObject:= New ( ChildPtr, Init );
  with MyObject^ do
    begin
      O;
      K;
    end { with };
  Dispose ( MyObject, Fini );
end.
