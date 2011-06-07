Program TestOUnit;

{$W-}

uses
  ObjUnit;

begin
  MyObject:= New ( ChildPtr, Init );
  with MyObject^ do
    begin
      O;
      K;
    end { with };
  Dispose ( MyObject, Fini );
end.
