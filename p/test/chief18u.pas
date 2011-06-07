unit one;
interface
  function positive(const i:integer):boolean;
implementation
  function positive(const i:integer):boolean;
  begin
    positive := i > 0;
  end;
end.
