Program Test;

{ $define debug}

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

{ Fixed: Object declarations in two type blocks did not work. }

Type
PNewObj = ^NewObj;
NewObj  = Object (TObject)
   Constructor Create (aOwner:pObject);
End; { NewObj }

Constructor NewObj.Create;
Begin
   Inherited Create (aOwner);
   Name := 'Object Number 2 is a Child!';
   Handle := -40;
End; { NewObj.Create }

{ Program() }
Var
ThisObj : TObject;
Begin
{  WriteLn ('Hello World!'); }
  ThisObj.Init;
  With ThisObj do Begin
     Handle := -1;
     Name   := { 'Object Number 1'; } 'OK';
     Child  := New (PNewObj, Create (@ThisObj) );
{
     WriteLn ('My handle    = ', Handle);
     WriteLn ('My name      = ', Name);
     WriteLn ('Child handle = ', Child^.Handle);
     WriteLn ('Child name   = ', Child^.Name);
     WriteLn ('Child PARENT handle = ', Child^.Parent^.Handle);
}
     WriteLn ( Child^.Parent^.Name );
     Child^.Free;
     Done;
  End; { With Ob^ }
{  WriteLn ('Hello World Number 2 !!'); }
End { Program() }.
