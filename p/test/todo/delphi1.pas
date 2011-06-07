program obctp01;

{$APPTYPE CONSOLE} // text-mode application

uses
  Classes;

type
  TAnimal = Class (TObject)
  protected
    Procedure DoSound; virtual;
  public
    Procedure MakeSound;
  end;

Procedure TAnimal.DoSound;
begin
  WriteLn ('OK');
end;

Procedure TAnimal.MakeSound;
begin
  DoSound;
end;

VAR Animal : TAnimal;

begin
  Animal := TAnimal.Create;
  Animal.MakeSound;
  Animal.Free;
end.
