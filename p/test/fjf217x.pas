unit fjf217x;

interface

uses fjf217w;

type
  TC = object
    Messages : pm;
    procedure RaiseMessage (Message : pm);
  end;

implementation

procedure TC.RaiseMessage (Message : pm);
begin
  Message^.Next := Messages;
  Messages := Message
end;

end.
