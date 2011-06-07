program igor2;

type
  LinesInfoPtr = ^LinesInfoType;
  LinesInfoType = array [0..99] of byte;

type

  EEPROMType = record
    LinesInfo: byte;
  end;

type
  StoragePtr = ^StorageType;
  StorageType = array [0..99] of byte;

type
  EEPROMPtr = ^EEPROMType;

var
  EEPROMStor: StoragePtr;
  EEPROMData: EEPROMPtr absolute EEPROMStor;

function EEP (    W: byte): EEPROMPtr;

begin
  EEP := EEPROMData
end;

function EAdvLineInfo (Line: ShortWord): byte;
begin
  EAdvLineInfo :=
    LinesInfoPtr (EEP (EEPROMData^.LinesInfo))^ [Line];
end;

var store : array [0..99] of byte;
{$W-}
begin
  store[0] := ord('O');
  EEPROMStor := StoragePtr(@(store[0]));
  writeln (char(EAdvLineInfo (0)), 'K');
end.

