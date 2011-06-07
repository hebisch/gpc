Unit martin3u;
Interface

Const MaxA=5;
      MaxB=62;

Type TPackedBoolean=Packed Array[1..MaxA] of Packed Array[1..MaxB] of Boolean;
     TRecord = Record
                 C:Integer;
                 PackedBoolean:TPackedBoolean;
                 D:Integer;
                End;

Var ARecord:TRecord;

Implementation

End.
