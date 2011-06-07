program Nicola4b;

type
  TString = String (2048);

procedure Routine (const Name: String);
var
  Str1, Str2, Str3, Str4, Str5, Str6: TString;
var
  StringRecordArray: array [1 .. 6] of record
    StringPointer: ^String
  end =
    ((@Str1), (@Str2), (@Str3), (@Str4), (@Str5), (@Str6));

  procedure SubRoutine;
  begin
  end;

begin
end;

begin
  WriteLn ('OK')
end.
