unit two;
interface
uses one in 'chief18u.pas';
  function negative(const i:integer):boolean;
  function neutral(const i:integer):boolean;
implementation
  function positive(const i:integer):boolean;
  begin
    WriteLn ('failed');
    positive := i > 0;
  end;

  function neutral(const i:integer):boolean;
  begin
    neutral := i = 0;
  end;

  function negative(const i:integer):boolean;
  begin
    negative := i < 0;
  end;
end.
