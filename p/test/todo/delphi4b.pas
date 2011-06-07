program obctp04;

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

  TObjectClass = Class of TObject;

  TDog = Class (TAnimal)
  protected
    Procedure DoSound; override;
  end;

  TFish = Class (TAnimal)
  protected
    Procedure DoSound; override;
  end;

  TCow = Class (TAnimal)
  protected
    Procedure DoSound; override;
  end;

  TComputer = Class (TObject)
  protected
    Procedure DoBeep; Virtual;
  public
    Procedure Beep;
  end;

Procedure TAnimal.MakeSound;
begin
  DoSound;
end;

Procedure TDog.DoSound;
begin
  WriteLn ('failed: Wuff');
end;

Procedure TFish.DoSound;
begin
  WriteLn ('failed: Blub Blub');
end;

Procedure TCow.DoSound;
begin
  WriteLn ('failed: Muuuh');
end;

Procedure TComputer.DoBeep;
begin
  WriteLn ('OK');
end;

Procedure TComputer.Beep;
begin
  DoBeep;
end;

VAR Animal : TObject;
    AnimalClass : TObjectClass;
    c : Integer;

begin
  {
  WriteLn ('Choose a animal: 1) Dog 2) Fish 3) Cow');
  ReadLn (c);
  }
  c := 42;

  Case c of
    1 : AnimalClass := TDog;
    2 : AnimalClass := TFish;
    3 : AnimalClass := TCow;
    else AnimalClass := TComputer; // is not an animal
  end;

  Animal := AnimalClass.Create;
  If Animal is TAnimal then // is it an animal
  begin
    (Animal as TAnimal).MakeSound;  // Let's see what happens
  end
  else
  begin
    (Animal as TComputer).Beep;  // Let's see what happens
  end;
  Animal.Free;
end.
