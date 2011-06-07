program Mainprg;

uses
  u1 in 'jesper2u.pas', u2 in 'jesper2v.pas';

var
  y : recPtr;

begin
  New (y);

  Proc2 (y);  { This call results in an incompatible pointer call }
end.          { Note that proc2 is in u2, where as recPtr is      }
              { defined in u1.                                    }
