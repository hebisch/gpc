{ Gives an error in fact (as of 20021130), due to the handling of
  `virtual' as a conditional keyword, but I think that's alright. -- Frank }

program fjf717c;

type
  a = abstract object
    procedure foo; virtual; virtual;  { WARN }
  end;

begin
  WriteLn ('failed')
end.
