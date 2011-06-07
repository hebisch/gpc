Program Test;

{$define debug}

uses
  Chief4;

Var
  ThisObj : TObject;

Begin
  ThisObj.Init;
  With ThisObj do Begin
     Handle := -1;
     Name   := 'OK';
     Child  := New (PNewObj, Create (@ThisObj) );
     WriteLn (Child^.Parent^.Name);
     Child^.Free;
     Done;
  End; { With Ob^ }
End { Program() }.
