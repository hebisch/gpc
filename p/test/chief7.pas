Program Test;

Uses {$ifdef Windows}wincrt,{$endif}MyObj in 'chief6.pas';

Type

pNewObj = ^TNewObj;
TNewObj = Object (TObject)
   Constructor Create (aOwner:pObject);
End; { TNewObj }

Constructor TNewObj.Create;
Begin
  Inherited Create (aOwner);
  Name   := 'Object Child';
  Handle := 2000;
End;  { TNewObj.Create }


{ Program() }
Var
ThisObj : TObject;

Begin
{
  WriteLn ('Hello World. Program Begins Here!');
  WriteLn ('---------------------------------');
}
  ThisObj.Init;
  With ThisObj Do Begin
     Name    := 'Object Number 1';
     Name    := 'OK';
     Handle  := 1000;
     Child   := New (pNewObj, Create (@ThisObj) );
{
     WriteLn ('My SelfID    = ', SelfID);
     WriteLn ('My Handle    = ', Handle);
     WriteLn ('My name      = ', Name);
     WriteLn ('Child SelfID = ', Child^.SelfID);
     WriteLn ('Child Handle = ', Child^.Handle);
     WriteLn ('Child name   = ', Child^.Name);
     WriteLn ('Child PARENT SelfID = ', Child^.Parent^.SelfID);
     WriteLn ('Child PARENT Handle = ', Child^.Parent^.Handle);
}
     WriteLn ( Child^.Parent^.Name );
     Child^.Free;
     Done;
  End; { With ThisObj }
{
  WriteLn ('---------------------------------');
  WriteLn ('Hello World. Program Ends Here!!');
}
  {$ifdef Windows}ReadKey;DoneWinCRT{$endif}
End. { Program() }
