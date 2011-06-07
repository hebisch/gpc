Unit Chief4;

{ $define debug}

Interface

Type
PObject  = ^TObject;
ChildPtr = PObject;

TObject  = Object
   Parent      : PObject;
   Child       : ChildPtr;
   Name        : String[255];
   Handle      : integer;

   { BP }
   Constructor Init;
   Destructor  Done;virtual;

   { Delphi }
   Procedure   Free;virtual;  {calls Destroy}
   Destructor  Destroy;virtual;
   Constructor Create (aOwner : PObject);
End; { TObject }

Type
PNewObj = ^NewObj;
NewObj  = Object (TObject)
   Constructor Create (aOwner:PObject);
End; { NewObj }

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
   Dispose (PObject (@Self), Destroy);
End; { TObject.Free }
{////////////}

Constructor NewObj.Create;
Begin
   Inherited Create (aOwner);
   Name := 'Object Number 2 is a Child!';
   Handle := -40;
End; { NewObj.Create }

End.
