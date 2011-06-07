Program Bug;

uses
  RealDef in 'sven11u.pas';

type
  GetObjT = record
              IsMoved         : Boolean;
              case PType: Integer of
                1: (OriginalInt     : ^Integer;);
                { Die folgende Zeile scheint den "Abort!" zu verursachen }
                { Wenn ich MyReal in dieser Unit deklariere passiert nix }
                { MyReal gilt aber für mehrere Units und muß }
                { gelegentlich mal geändert werden }
                2: (OriginalFlt     : ^MyReal;);
                3: (OriginalBol     : ^Boolean;);
              end;

begin
  writeln ( 'OK' );
end.
