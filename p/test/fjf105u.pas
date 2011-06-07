unit fjf105u;

interface

const t = 17;

uses GPC;

const x = MaxLongInt;

implementation

const v = 1;

uses Overlay, StringUtils;

const w = OvrNotFound;

const y = DefaultHashSize;

uses MD5;

const z = BitSizeOf (Card8);

begin
  if not (    (t = 17)
          and (v = 1)
          and (w = OvrNotFound)
          and (x = High (LongInt))
          and (y >= 1)
          and (z = 8)) then
    begin
      WriteLn ('failed');
      Halt (1)
    end
end.
