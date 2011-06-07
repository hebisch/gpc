{ Test of the StringUtils unit }

program StringUtilsTest;

uses GPC, StringUtils;

var
  HashTable : PStrHashTable;
  p : Pointer;

procedure HashTest (a, b : Integer; q : Pointer);
var n : Integer = 0; attribute (static);
begin
  Inc (n);
  if a <> b then
    begin
      WriteLn ('failed #', n, ': ', a, ' <> ', b);
      Halt (1)
    end;
  if p <> q then
    begin
      WriteLn ('failed #', n, ': Pointer (', PtrInt (p), ') <> Pointer (', PtrInt (q), ')');
      Halt (1)
    end
end;

begin
  HashTable := NewStrHashTable (DefaultHashSize, True);
  AddStrHashTable (HashTable, 'foo', 42, nil);
  AddStrHashTable (HashTable, 'bar', -1, @HashTable);
  AddStrHashTable (HashTable, 'baz', 0, @p);
  HashTest (SearchStrHashTable (HashTable, 'foo', p), 42, nil);
  HashTest (SearchStrHashTable (HashTable, 'Bar', p), 0, nil);
  HashTest (SearchStrHashTable (HashTable, 'bar', p), -1, @HashTable);
  HashTest (SearchStrHashTable (HashTable, 'baz', Null), 0, @HashTable);
  HashTest (SearchStrHashTable (HashTable, 'baz', p), 0, @p);
  DisposeStrHashTable (HashTable);
  HashTable := NewStrHashTable (DefaultHashSize, False);
  HashTest (SearchStrHashTable (HashTable, 'foo', p), 0, nil);
  AddStrHashTable (HashTable, 'xfoo', 42, nil);
  AddStrHashTable (HashTable, 'xbar', -1, @HashTable);
  AddStrHashTable (HashTable, 'xbaz', 0, @p);
  HashTest (SearchStrHashTable (HashTable, 'xfoo', p), 42, nil);
  HashTest (SearchStrHashTable (HashTable, 'xBar', p), -1, @HashTable);
  HashTest (SearchStrHashTable (HashTable, 'xbaz', Null), 0, @HashTable);
  HashTest (SearchStrHashTable (HashTable, 'xbaz', p), 0, @p);
  DeleteStrHashTable  (HashTable, 'XBAR');
  HashTest (SearchStrHashTable (HashTable, 'xfoo', p), 42, nil);
  HashTest (SearchStrHashTable (HashTable, 'xBar', p), 0, nil);
  HashTest (SearchStrHashTable (HashTable, 'xbaz', Null), 0, nil);
  HashTest (SearchStrHashTable (HashTable, 'xbaz', p), 0, @p);
  DisposeStrHashTable (HashTable);
  WriteLn ('OK')
end.
