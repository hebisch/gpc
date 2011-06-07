unit babyunit;

interface
uses babyuni2;

procedure printmytype(b : MyType);

implementation

procedure printmytype(b : MyType);
begin
  case ord(b) of
    0: write ( 'O' );
    1: write ( 'K' );
    2: writeln;
  end
end;

end.
