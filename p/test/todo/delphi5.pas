program obctp05;

{$APPTYPE CONSOLE} // text-mode application

uses
  Classes;

type
  TAnimal = Class (TObject)
  protected
    Procedure DoSound; virtual; Abstract;
  public
    Procedure MakeSound;
  end;

Procedure TAnimal.MakeSound;
begin
  DoSound;
end;

VAR Animal : TAnimal;

begin
  {$W-}
  Animal := TAnimal.Create; // Abstract-compiler warning here
  {$W+}
  try
    Animal.MakeSound;  // Will raise an exception
  finally
    WriteLn ('OK');  // But the object will be freed
    Animal.Free;
  end;
  // But the exception itself is not handled,
  // so the following code will not be executed
  WriteLn ('failed');

// Perhaps we'll have to catch it again to prevent a runtime error, Frank
end.
