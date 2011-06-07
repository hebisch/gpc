program obctp03;

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

  TDog = Class (TAnimal)
  protected
    Procedure DoSound; override;
  end;

Procedure TAnimal.MakeSound;
begin
  DoSound;
end;

Procedure TDog.DoSound;
begin
  WriteLn ('OK');
end;

VAR Animal : TAnimal;

begin
  Animal := TDog.Create;
  Animal.MakeSound;
  Animal.Free;
end.
