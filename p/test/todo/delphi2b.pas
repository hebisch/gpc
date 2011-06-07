program obctp02;

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
  DoSound; // Abstract-RTE here
end;

VAR Animal : TAnimal;

begin
  {$W-}
  Animal := TAnimal.Create; // Abstract-compiler warning here
  {$W+}
  Animal.MakeSound;
  Animal.Free;
end.
