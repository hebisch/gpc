unit First;

interface

  procedure CallFirst;

implementation

uses
  Second in 'marius2v.pas';

procedure CallFirst;
begin
  CallSecond;
end;

end.
