program delphi1b;


type
  TAnimal = Class
  protected
    Procedure DoSound; virtual;
  public
    Constructor MakeAnimal;
    Destructor UnMakeAnimal;
    Procedure MakeSound;
  end;

Constructor TAnimal.MakeAnimal;
begin
end;

Destructor TAnimal.UnMakeAnimal;
begin
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
  Animal := TAnimal.MakeAnimal;
  Animal.MakeSound;
  Animal.UnMakeAnimal;
end.
