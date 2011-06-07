Unit Chief2;

{ $define debug}

Interface

Type
pObject  = ^TObject;
ChildPtr = pObject;

TObject  = Object
   Parent      : pObject;
   Child       : ChildPtr;
   Name        : String[255];
   Handle      : integer;

   { BP }
   Constructor Init;
   Destructor  Done;virtual;

   { Delphi }
   Procedure   Free;virtual;  {calls Destroy}
   Destructor  Destroy;virtual;
   Constructor Create (aOwner : pObject);
End; { TObject }

Implementation

Constructor TObject.Init;
Begin
   Parent := Nil;
End; { TObject.Init }
{////////////}
Constructor TObject.Create;
Begin
   Parent := aOwner;
End; { TObject.Create }
{////////////}
Destructor TObject.Done;
Begin
   Handle := 0;
   Name   := '';
   Parent := Nil;
End; { TObject.Done }
{////////////}
Destructor TObject.Destroy;
Begin
   Handle := 0;
   Name   := '';
   Parent := Nil;
End; { TObject.Destroy }
{////////////}
Procedure TObject.Free;
Begin
   {$ifdef debug}WriteLn ('Free!');{$endif debug}
   Dispose (pObject (@Self), Destroy);
End; { TObject.Free }
{////////////}

End.
