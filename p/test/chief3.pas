Program Test;

{$define debug}

uses
  Chief2;

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

Var
  ThisObj : TObject;

Begin
{ WriteLn ('Hello World!'); }
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
{ WriteLn ('Hello World Number 2 !!'); }
End { Program() }.
