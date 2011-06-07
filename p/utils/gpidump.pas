{ Dump the contents of GPI files. Useful for GPC developers.

  Copyright (C) 2002-2006 Free Software Foundation, Inc.

  Author: Frank Heckenbach <frank@pascal.gnu.de>

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License as
  published by the Free Software Foundation, version 3.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; see the file COPYING. If not, write to
  the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
  Boston, MA 02111-1307, USA. }

{$gnu-pascal,I+}
{$if __GPC_RELEASE__ < 20050101}
{$error This program requires GPC release 20050101 or newer.}
{$endif}

{ We should put various sizes in .gpi file:
for Amd64
  real_value 32 bytes
}

program GPIDump;

import GPC; StringUtils;

var
  Verbose, Hex: Boolean;

procedure ProcessFile (const GPIFileName: String);
type
  TTreeCode = ({$define DEFTREECODE(ID, NAME, CLASS, ARGS) ID, }
               {$local W no-identifier-case}
               {$include "tree.inc"}
               {$endlocal}
               {$undef DEFTREECODE}
               UnknownTreeCode);

const
  ExprClasses = ['e', '1', '2', '<', 's'];
  tcc_type = 't';
  tcc_declaration = 'd';
  tcc_constant = 'c';
  tcc_unary = '1';
  tcc_binary = '2';
  tcc_comparison = '<';
  tcc_expression = 'e';
  tcc_reference = 'r';
  tcc_exceptional = 'x';
  tcc_statement = 's';
  
  TreeCodes: array [TTreeCode] of record
    Name: ^String;
    CodeClass: Char;
    Arguments: Integer
  end =
    ({$define DEFTREECODE(ID, NAME, CLASS, ARGS) (@NAME, CLASS, ARGS), }
     {$include "tree.inc"}
     {$undef DEFTREECODE}
     (@'unknown tree code', #0));

{ Sanity check }
{$ifndef GCC_VERSION_SET}
{$error tree.inc not included or not correctly generated}
{$endif}

{$ifdef GCC_3_5}
{$error GPIDump not yet ported to gcc-3.5.x}
{$endif}

type
  GPIInt = MedCard;

  TOffsets (Size: Integer) = array [0 .. Size] of GPIInt;

  TBytesChars (Size: Integer) = record
  case Boolean of
    False: (Bytes: array [0 .. Max (0, Size - 1)] of Byte);
    True:  (Chars: array [0 .. Max (0, Size - 1)] of Char);
  end;

  TChunkCode = ({$define GPI_CHUNK(ID, REQUIRED, UNIQUE, NAME) ID }
                GPI_CHUNKS
                {$undef GPI_CHUNK});

const
  Chunks: array [TChunkCode] of record
    Name: PString;
    Required, Unique: Integer
  end = ({$define GPI_CHUNK(ID, REQUIRED, UNIQUE, NAME) (@NAME, REQUIRED, UNIQUE) }
         GPI_CHUNKS
         {$undef GPI_CHUNK});

  SpecialNodes: array [0 .. {$define SN(NODE) + 1} SPECIAL_NODES {$undef SN}] of PString =
    {$define SN(NODE) , @#NODE} (nil SPECIAL_NODES) {$undef SN};

var
  f: File;
  Header: array [1 .. Length (GPI_HEADER)] of Char;
  ChunkCodeNum: Byte;
  ChunkCode: TChunkCode;
  ChunksSeen: set of TChunkCode;
  ChunkLength, CheckSum, NodesPos1, NodesPos2, Pos1, Pos2, i: GPIInt;
  Buf, Nodes: ^TBytesChars;
  Offsets: ^TOffsets;
  DebugKey: Boolean;
  Target: TString;

  procedure Warning (const Msg: String);
  begin
    WriteLn (StdErr, ParamStr (0), ':', GPIFileName, ': warning: ', Msg)
  end;

  procedure Error (const Msg: String);
  begin
    WriteLn;
    WriteLn (StdErr, ParamStr (0), ':', GPIFileName, ': ', Msg);
    Halt (1)
  end;

  function IsSpecialNode (i: GPIInt; const Name: String): Boolean;
  begin
    IsSpecialNode := (i < High (SpecialNodes)) and (SpecialNodes[i + 1]^ = Name)
  end;

  function Number (i: LongestCard; MinDigits: Integer) = s: TString;
  var
    j: LongestInt;
    k: Integer;
  begin
    if not Hex then
      WriteStr (s, i)
    else
      begin
        s := '';
        j := 1;
        for k := 2 to MinDigits do
          j := $10 * j;
        while j <= i div $10 do
          j := $10 * j;
        while j > 0 do
          begin
            s := s + NumericBaseDigits[i div j];
            i := i mod j;
            j := j div $10
          end
      end
  end;

  procedure DumpBytes (const Prefix: String; Lo, Hi: Integer);
  var i: Integer;
  begin
    Write (Prefix);
    for i := Lo to Hi do
      begin
        if ((i - Lo) mod 16 = 0) and (i > Lo) then
          begin
            WriteLn;
            Write ('' : Length (Prefix))
          end;
        Write (Number (Buf^.Bytes[i], 2) : 4 - Ord (Hex))
      end
  end;

  procedure DumpChars (const Prefix: String; Lo, Hi: Integer);
  var
    i: Integer;
    SpecialChar, Quote: Boolean;
  begin
    SpecialChar := False;
    for i := Lo to Hi do
      if not IsPrintable (Buf^.Chars[i]) then
        SpecialChar := True;
    if not SpecialChar then
      if Lo = Hi + 1 then
        Write (Prefix, '`''')
      else
        Write (Prefix, '`', Buf^.Chars[Lo .. Hi], '''')
    else
      begin
        Write (Prefix);
        Quote := False;
        for i := Lo to Hi do
          if IsPrintable (Buf^.Chars[i]) then
            begin
              if not Quote then Write ('`');
              Quote := True;
              Write (Buf^.Chars[i])
            end
          else
            begin
              if Quote then Write ('''');
              Quote := False;
              Write ('#', Number (Ord (Buf^.Chars[i]), 0))
            end;
        if Quote then Write ('''')
      end
  end;

  procedure GetSize (var Pos: GPIInt; var Dest; Size: Integer);
  begin
    Move (Nodes^.Bytes[Pos], Dest, Size);
    Inc (Pos, Size)
  end;

  function GetNumber (var Pos: GPIInt) = Res: GPIInt;
  begin
    GetSize (Pos, Res, SizeOf (Res))
  end;

  { Must match compute_checksum() in module.c }
  function ComputeChecksum (const Buf: array of Byte) = Sum: GPIInt;
  var n: GPIInt;
  begin
    Sum := 0;
    for n := 0 to High (Buf) do
      {$local R-} Inc (Sum, n * Buf[n]) {$endlocal}
  end;

  { @@ This must correspond precisely to what module.c does. }
  procedure DumpNode (NodeNumber, Pos1, Pos2: GPIInt);
  const
    LangCodeNormal                 =  0;
    LangCodeVariantRecord          =  1;
    LangCodeNonTextFile            =  2;
    LangCodeTextFile               =  3;
    LangCodeObject                 =  4;
    LangCodeAbstractObject         =  5;
    LangCodeUndiscriminatedString  =  6;
    LangCodePrediscriminatedString =  7;
    LangCodeDiscriminatedString    =  8;
    LangCodeUndiscriminatedSchema  =  9;
    LangCodePrediscriminatedSchema = 10;
    LangCodeDiscriminatedSchema    = 11;
    LangCodeFakeArray              = 12;

  var
    First, ClassDone, IsMethod, IsPackedAccess: Boolean;
    TempPos, a, b, i: GPIInt;
    InterfaceNode, InterfaceUID: GPIInt;
    TreeCodeNum, LangCode: Byte;
    TreeCode: TTreeCode;

    procedure Comma;
    begin
      if First then
        Write (' ')
      else
        Write (', ');
      First := False
    end;

    procedure Comma0;
    begin
      if not First then Write (', ');
      First := False
    end;

    procedure Str (const Prefix: String);
    var l: GPIInt;
    begin
      l := GetNumber (Pos1);
      Comma;
      DumpChars (Prefix, Pos1, Pos1 + l - 1);
      Inc (Pos1, l)
    end;

    function OptStr (const Prefix: String): Boolean;
    var l: GPIInt;
    begin
      OptStr := False;
      l := GetNumber (Pos1);
      if l = 0 then Exit;
      Comma;
      DumpChars (Prefix, Pos1, Pos1 + l - 1);
      Inc (Pos1, l);
      OptStr := True
    end;

    procedure Str0 (const Prefix: String);
    var l: GPIInt;
    begin
      Comma;
      l := GetNumber (Pos1);
      DumpChars (Prefix + ' ', Pos1, Pos1 + l - 1 - Ord (Nodes^.Bytes[Pos1 + l - 1] = 0));
      Inc (Pos1, l)
    end;

    procedure OutputRef (i: GPIInt);
    begin
      { Don't write `null_tree_node', but simply 0. }
      if (i > 0) and (i < High (SpecialNodes)) then
        Write (SpecialNodes[i + 1]^)
      else
        Write (Number (i, 0))
    end;

    procedure Ref (const Prefix: String);
    begin
      Comma;
      Write (Prefix, ' <');
      OutputRef (GetNumber (Pos1));
      Write ('>')
    end;

    function OptRefFunc (const Prefix: String): Boolean;
    var n: GPIInt;
    begin
      n := GetNumber (Pos1);
      if n <> 0 then
        begin
          Comma;
          Write (Prefix, ' <');
          OutputRef (n);
          Write ('>')
        end;
      OptRefFunc := n <> 0
    end;

    procedure OptRef (const Prefix: String);
    begin
      Discard (OptRefFunc (Prefix))
    end;

    procedure OutputFlag (const Flag: String);
    begin
      if Flag[1] = '!' then Error ('unexpected flag `' + Copy (Flag, 2) + '''');
      Comma;
      Write (Flag)
    end;

    procedure OutputFlag2 (const Flag: String; n: Integer);
    begin
      Comma;
      Write (Flag, ' ', n)
    end;

    procedure Flags;
    var
      f: packed record
        Code: Byte;
        side_effects,
        constant,
        {$ifndef EGCS97}
        permanent,
        {$endif}
        addressable,
        volatile,
        readonly,
        unsigned,
        asm_written,
        {$ifdef EGCS97}
        unused_flag_0,
        {$endif}
        used,
        {$ifdef EGCS97}
        nothrow,
        {$else}
        raises,
        {$endif}
        static,
        fpublic,
        fprivate,
        fprotected,
        {$ifdef GCC_3_4}
        deprecated,
        invariant,
        {$elif defined (EGCS97)}
        bounded,
        deprecated,
        {$endif}
        unused_lang_flag_0,
        unused_lang_flag_1,
        lang_flag_2,
        lang_flag_3,
        lang_flag_4,
        lang_flag_5,
        lang_flag_6,
        {$ifdef EGCS97}
        unused_flag_2: Boolean
        {$else}
        unknown_flag_1,
        unknown_flag_2,
        unknown_flag_3: Boolean
        {$endif}
      end;
    begin
      CompilerAssert (SizeOf (f) = 4);
      GetSize (Pos1, f, SizeOf (f));
      if f.Code <> Ord (TreeCode) then
        Error ('tree code in flags does not match');
      if f.side_effects then OutputFlag ('side_effects');
      if TreeCodes[TreeCode].CodeClass = 'c' then
        begin
          if not f.constant then Error ('constant has `constant'' flag not set')
        end
      else
        if f.constant then OutputFlag ('constant');
      {$ifndef EGCS97}
      if not f.permanent then Error ('`permanent'' flag not set');
      {$endif}
      if f.addressable then OutputFlag ('addressable');
      if f.volatile then OutputFlag ('volatile');
      if f.readonly then OutputFlag ('readonly');
      if f.unsigned then OutputFlag ('unsigned');
      if f.asm_written then OutputFlag ('asm_written');
      {$ifdef EGCS97}
      if f.unused_flag_0 then OutputFlag ('!unused_flag_0');
      {$endif}
      if f.used then OutputFlag ('used');
      {$ifdef EGCS97}
      if f.nothrow then OutputFlag ('nothrow');
      {$else}
      if f.raises then OutputFlag ('raises');
      {$endif}
      if f.static then OutputFlag ('static');
      if f.fpublic then OutputFlag ('public');
      if f.fprivate then OutputFlag ('private');
      if f.fprotected then OutputFlag ('protected');
      {$ifdef GCC_3_4}
      if f.deprecated then OutputFlag ('!deprecated');
      if f.invariant then OutputFlag (
        {$ifdef GCC_4_0} 'invariant' {$else} '!unused_flag_1' {$endif});
      {$elif defined (EGCS97)}
      if f.bounded then OutputFlag ('bounded');
      if f.deprecated then OutputFlag ('!deprecated');
      {$endif}
      if f.unused_lang_flag_0 then OutputFlag ('!unused_lang_flag_0');
      if f.unused_lang_flag_1 then OutputFlag ('!unused_lang_flag_1');
      if f.lang_flag_2 then
        if (TreeCodes[TreeCode].CodeClass in (ExprClasses + ['c'])) or (TreeCode = FUNCTION_TYPE) then
          OutputFlag ('ignorable')
        else
          case TreeCode of
            PARM_DECL,
            TREE_LIST: OutputFlag ('same_id_list');
            else       OutputFlag ('!lang flag 2')
          end;
      if f.lang_flag_3 then
        if TreeCodes[TreeCode].CodeClass = 't' then
          OutputFlag ('value_parameter_by_reference')
        else
          case TreeCode of
            VAR_DECL,
            FIELD_DECL,
            CONVERT_EXPR:  OutputFlag ('discriminant');
            else           OutputFlag ('!lang flag 3')
          end;
      if f.lang_flag_4 then
        case TreeCode of
          FUNCTION_DECL: OutputFlag ('structor');
          TREE_LIST:     OutputFlag ('bp_initializer');
          INTEGER_CST,
          NON_LVALUE_EXPR:
                         OutputFlag ('pascal_cst_parentheses');
          else           OutputFlag ('!lang flag 4')
        end;
      if f.lang_flag_5 then
        case TreeCode of
          NON_LVALUE_EXPR,
          TREE_LIST:     begin
                           OutputFlag ('packed_access');
                           IsPackedAccess := True
                         end;
          INTEGER_CST,
          REAL_CST,
          COMPLEX_CST,
          STRING_CST:    OutputFlag ('fresh_constant');
          VAR_DECL:      OutputFlag ('had_side_effects');
          FUNCTION_DECL: OutputFlag ('virtual');
          CONSTRUCTOR:   OutputFlag ('constructor_int_cst');
          POINTER_TYPE:  OutputFlag ('class');
          else           OutputFlag ('!lang flag 5')
        end;
      if f.lang_flag_6 then
        if TreeCodes[TreeCode].CodeClass in ExprClasses then
          OutputFlag ('absolute')
        else if TreeCodes[TreeCode].CodeClass = 't' then
          OutputFlag ('const_parm')
        else
          case TreeCode of
            IDENTIFIER_NODE: OutputFlag ('qualified');
            FUNCTION_DECL:   OutputFlag ('abstract');
            VAR_DECL:        OutputFlag ('prog_heading');
            else             OutputFlag ('!lang flag 6')
          end;
      {$ifdef EGCS97}
      if f.unused_flag_2 then OutputFlag ('!unused_flag_2');
      {$else}
      if f.unknown_flag_1 then OutputFlag ('!unknown_flag_#1');
      if f.unknown_flag_2 then OutputFlag ('!unknown_flag_#2');
      if f.unknown_flag_3 then OutputFlag ('!unknown_flag_#3');
      {$endif}
    end;

    procedure TypeFlags;
    var
      f: packed record
        {$ifdef EGCS97}
        Precision: 0 .. 511;
        MachineMode: 0 .. 127;
        {$else}
        Precision, MachineMode: Byte;
        {$endif}
        fstring,
        no_force_blk,
        needs_constructing,
        transparent_union,
        fpacked: Boolean;
        {$ifdef EGCS}
        restrict: Boolean;
        {$endif}
        {$ifdef GCC_3_4}
        spare: 0 .. 3;
        {$elif defined (EGCS97)}
        pointer_depth: 0 .. 3;
        {$endif}
        unused_type_flag_0,
        iocritical,
        frestricted,
        fbindable,
        type_flag_4,
        type_flag_5,
        unused_type_flag_6: Boolean;
        {$ifdef EGCS97}
        user_align: Boolean;
        {$else}
        unknown_type_flag_1,
        unknown_type_flag_2,
        unknown_type_flag_3: Boolean;
        {$endif}
        {$ifndef EGCS}
        unknown_type_flag_4: Boolean;
        {$endif}
        Align: CCardinal
      end;
    begin
      CompilerAssert (SizeOf (f) = SizeOf (CCardinal) + 4);
      GetSize (Pos1, f, SizeOf (f));
      Comma;
      {$ifdef GCC_3_3}
      Write ('precision ', Number (f.Precision + (f.MachineMode mod 1) * 256, 0),
             ', machine_mode ', Number (f.MachineMode div 2, 0));
      {$else}
      Write ('precision ', Number (f.Precision, 0),
             ', machine_mode ', Number (f.MachineMode, 0));
      {$endif}
      if f.fstring then OutputFlag ('string');
      if f.no_force_blk then OutputFlag ('no_force_blk');
      if f.needs_constructing then OutputFlag ('needs_constructing');
      if f.transparent_union then OutputFlag ('transparent_union');
      if f.fpacked then OutputFlag ('packed');
      {$ifdef EGCS}
      if f.restrict then OutputFlag ('restrict');
      {$endif}
      {$ifdef GCC_3_4}
      if f.spare <> 0 then OutputFlag ('!spare');
      {$elif defined (EGCS97)}
      OutputFlag2 ('pointer_depth', f.pointer_depth);
      {$endif}
      if f.unused_type_flag_0 then OutputFlag ('!unused_type_flag_0');
      if f.iocritical then OutputFlag ('iocritical');
      if f.frestricted then OutputFlag ('restricted');
      if f.fbindable then OutputFlag ('bindable');
      if f.type_flag_4 then
        case TreeCode of
          ARRAY_TYPE,
          INTEGER_TYPE: OutputFlag ('open_array');
          RECORD_TYPE,
          UNION_TYPE:   OutputFlag ('record_variants');
          else          OutputFlag ('!type_decl_flag_4')
        end;
      if f.type_flag_5 then
        case TreeCode of
          ARRAY_TYPE:    OutputFlag ('intermediate_array');
          RECORD_TYPE:   OutputFlag ('initializer_from_components');
          BOOLEAN_TYPE,
          CHAR_TYPE,
          INTEGER_TYPE,
          ENUMERAL_TYPE: OutputFlag ('conformant_array_bound');
          else           OutputFlag ('!type_decl_flag_5')
        end;
      if f.unused_type_flag_6 then OutputFlag ('!unused_type_flag_6');
      {$ifdef EGCS97}
      if f.user_align then OutputFlag ('user_align');
      {$else}
      if f.unknown_type_flag_1 then OutputFlag ('!unknown_type_flag_#1');
      if f.unknown_type_flag_2 then OutputFlag ('!unknown_type_flag_#2');
      if f.unknown_type_flag_3 then OutputFlag ('!unknown_type_flag_#3');
      {$endif}
      {$ifndef EGCS}
      if f.unknown_type_flag_4 then OutputFlag ('!unknown_type_flag_#4');
      {$endif}
      Write (', align ', Number (f.Align, 0))
    end;

    procedure DeclFlags;
    type
      TDeclMisc = {$ifdef EGCS97} Integer { @@ HOST_WIDE_INT } {$else} Integer {$endif};
    var
      f: packed record
        MachineMode: Byte;
        c_external,
        nonlocal,
        regdecl,
        inline,
        bit_field,
        c_virtual,
        ignored,
        c_abstract,
        in_system_header,
        common,
        defer_output,
        transparent_union,
        static_ctor,
        static_dtor,
        artificial,
        weak: Boolean;
        {$ifdef EGCS97}
        non_addr_const_p,
        no_instrument_function_entry_exit,
        comdat_flag,
        malloc_flag,
        no_limit_stack: Boolean;
        built_in_class: 0 .. 3;
        pure_flag: Boolean;
        {$ifndef GCC_3_4}
        pointer_depth: 0 .. 3;
        {$endif}
        non_addressable,
        user_align,
        uninlinable: Boolean;
        {$ifdef GCC_3_3}
        thread_local,
        declared_inline_flag: Boolean;
        {$endif}
        {$ifdef GCC_4_0}
        seen_in_bind_expr: Boolean;
        {$endif}
        {$ifdef GCC_3_4}
        visibility: 0 .. 3;
        visibility_specified: Boolean;
        {$endif}
        {$endif}
        unused_decl_flag_0,
        imported,
        imported_uses,
        bp_typed_const,
        decl_flag_4,
        decl_flag_5,
        decl_flag_6,
        decl_flag_7: Boolean;
        {$ifdef GCC_4_0}
        possibly_inlined,
        preserve_flag,
        gimple_formal_temp,
        debug_expr_is_from : Boolean;
        sp1, sp2, sp3, sp4, sp5, sp6, sp7,
        sp8, sp9, sp10, sp11 : Boolean;
        {$endif}
        {$if defined (EGCS) and not defined (EGCS97)}
        non_addr_const_p,
        no_instrument_function_entry_exit,
        no_check_memory_usage,
        comdat_flag: Boolean;
        {$endif}
        Misc: TDeclMisc
      end;
    begin
      CompilerAssert (SizeOf (f) = {$ifdef GCC_4_0} 8 
                           {$elif defined (EGCS97)} 6 
                             {$elif defined (EGCS)} 5
                                            {$else} 4
                            {$endif} + SizeOf (TDeclMisc));
      GetSize (Pos1, f, SizeOf (f));
      Comma;
      Write ('machine_mode ', Number (f.MachineMode, 0));
      if f.c_external then OutputFlag ('c_external');
      if f.nonlocal then OutputFlag ('nonlocal');
      if f.regdecl then OutputFlag ('regdecl');
      if f.inline then OutputFlag ('inline');
      if f.bit_field then OutputFlag ('bit_field');
      if f.c_virtual then OutputFlag ('c_virtual');
      if f.ignored then OutputFlag ('ignored');
      if f.c_abstract then OutputFlag ('c_abstract');
      if f.in_system_header then OutputFlag ('in_system_header');
      if f.common then OutputFlag ('common');
      if f.defer_output then OutputFlag ('defer_output');
      if f.transparent_union then OutputFlag ('transparent_union');
      if f.static_ctor then OutputFlag ('static_ctor');
      if f.static_dtor then OutputFlag ('static_dtor');
      if f.artificial then OutputFlag ('artificial');
      if f.weak then OutputFlag ('weak');
      {$ifdef EGCS97}
      if f.non_addr_const_p then OutputFlag ('non_addr_const_p');
      if f.no_instrument_function_entry_exit then OutputFlag ('no_instrument_function_entry_exit');
      if f.comdat_flag then OutputFlag ('comdat_flag');
      if f.malloc_flag then OutputFlag ('malloc_flag');
      if f.no_limit_stack then OutputFlag ('no_limit_stack');
      OutputFlag2 ('built_in_class', f.built_in_class);
      if f.pure_flag then OutputFlag ('pure_flag');
      {$ifndef GCC_3_4}
      OutputFlag2 ('pointer_depth', f.pointer_depth);
      {$endif}
      if f.non_addressable then OutputFlag ('non_addressable');
      if f.user_align then OutputFlag ('user_align');
      if f.uninlinable then OutputFlag ('uninlinable');
      {$ifdef GCC_3_3}
      if f.thread_local then OutputFlag ('thread_local');
      if f.declared_inline_flag then OutputFlag ('declared_inline_flag');
      {$endif}
      {$ifdef GCC_3_4}
      OutputFlag2 ('visibility', f.visibility);
      if f.visibility_specified then OutputFlag (
           {$ifdef GCC_4_0} 'visibility_specified' {$else} '!unused' {$endif});
      {$endif}
      {$endif}
      if f.unused_decl_flag_0 then OutputFlag ('!unused_decl_flag_0');
      if f.imported then OutputFlag ('imported');
      if f.imported_uses then OutputFlag ('imported_uses');
      if f.bp_typed_const then
        case TreeCode of
          FUNCTION_DECL,
          FIELD_DECL: OutputFlag ('shadowed_field');
          LABEL_DECL: OutputFlag ('label_set');
          VAR_DECL:   OutputFlag ('bp_typed_const');
          else        OutputFlag ('!lang_decl_flag_3')
        end;
      if f.decl_flag_4 then
        case TreeCode of
          FIELD_DECL: OutputFlag ('packed_field');
          VAR_DECL:   OutputFlag ('pascal_value_assigned');
          else        OutputFlag ('!lang_decl_flag_4')
        end;
      if f.decl_flag_5 then
        case TreeCode of
          FUNCTION_DECL: begin
                           OutputFlag ('method');
                           IsMethod := True
                         end;
          OPERATOR_DECL: OutputFlag ('also_built_in');
          else           OutputFlag ('!lang_decl_flag_5')
        end;
      if f.decl_flag_6 then
        case TreeCode of
          VAR_DECL:  OutputFlag ('initialized');
          PARM_DECL: OutputFlag ('procedural_parameter');
          FUNCTION_DECL: 
                     OutputFlag ('reintroduce');
          else       OutputFlag ('!lang_decl_flag_6')
        end;
      if f.decl_flag_7 then
        case TreeCode of
          FUNCTION_DECL: OutputFlag ('forward');
          CONST_DECL:    OutputFlag ('principal');
          VAR_DECL:      OutputFlag ('for_loop_counter');
          else           OutputFlag ('!lang_decl_flag_7')
        end;
      {$if defined (EGCS) and not defined (EGCS97)}
      if f.non_addr_const_p then OutputFlag ('non_addr_const_p');
      if f.no_instrument_function_entry_exit then OutputFlag ('no_instrument_function_entry_exit');
      if f.no_check_memory_usage then OutputFlag ('no_check_memory_usage');
      if f.comdat_flag then OutputFlag ('comdat_flag');
      {$endif}
      Write (', misc ', Number (f.Misc, 0))
    end;

    procedure IntConst (const Prefix: String);
    var
      Lo: GPIInt;
      Num: LongestInt;
    begin
      Comma;
      Write (Prefix, ' ');
      Lo := GetNumber (Pos1);
      Num := GetNumber (Pos1);
      if Num >= $80000000 then Dec (Num, $100000000);
      Num := $100000000 * Num + Lo;
      if Num = High (Integer) then
        Write ('MaxInt')
      else if Num = Low (Integer) then
        Write ('MinInt')
      else if Num = High (Cardinal) then
        Write ('MaxCard')
      else if Num = High (LongInt) then
        Write ('MaxLongInt')
      else if Num = Low (LongInt) then
        Write ('MinLongInt')
      else if Num = High (LongCard) then
        Write ('MaxLongCard')
      else
        begin
          if Num < 0 then
            begin
              Num := -Num;
              Write ('-')
            end;
          Write (Number (Num, 0))
        end
    end;

    procedure RealConst (const Prefix: String);
    var RealSize: Integer;
    begin
      { @@ ../real.h: REAL_VALUE_TYPE }
      {$ifdef GCC_3_3}
      {$ifdef __LP64__}
      RealSize := 32;
      {$else}
      RealSize := 24;
      {$endif}
      {$elif defined (EGCS97)}
      RealSize := 20;
      {$else}
      if PosCase ('sparc', Target) <> 0 then
        RealSize := 20
      else if (PosCase ('mips', Target) <> 0) or
              (PosCase ('alpha', Target) <> 0) then
        RealSize := 8
      else
        RealSize := 12;
      {$endif}
      Comma;
      DumpBytes (Prefix + ' (', Pos1, Pos1 + RealSize - 1);
      Write (')');
      Inc (Pos1, RealSize)
    end;

    procedure FieldOffset;
    begin
      {$ifdef EGCS97}
      Ref ('bit_offset');
      First := True;
      Ref ('offset')
      {$else}
      Ref ('bitpos')
      {$endif}
    end;

  begin
    TempPos := Pos1;
    if DebugKey and (GetNumber (Pos1) <> GPI_DEBUG_KEY) then
      Error ('invalid debug key');
    InterfaceNode := GetNumber (Pos1);
    InterfaceUID := 0;
    if InterfaceNode <> 0 then InterfaceUID := GetNumber (Pos1);
    GetSize (Pos1, TreeCodeNum, SizeOf (TreeCodeNum));
    if TreeCodeNum >= Ord (High (TreeCode)) then
      TreeCode := High (TreeCode)
    else
      TreeCode := TTreeCode (TreeCodeNum);
    Write ('<', Number (NodeNumber, 0), '>');
    if Verbose then
      Write (' (offset: ', Number (TempPos + NodesPos1, 0), ' .. ', Number (Pos2 + NodesPos1, 0), ')',
             ', tree code ', Number (TreeCodeNum, 2));
    Write (': ', TreeCodes[TreeCode].Name^);
    if InterfaceNode <> 0 then
      begin
        Write (', interface <');
        OutputRef (InterfaceNode);
        Write ('>: ', Number (InterfaceUID, 0))
      end;
    WriteLn;
    if Verbose then
      begin
        DumpBytes ('Raw bytes: ', TempPos, Pos2);
        WriteLn
      end;
    First := True;
    if not (TreeCode in [IDENTIFIER_NODE, INTERFACE_NAME_NODE, TREE_LIST]) then Flags;
    ClassDone := False;
    IsMethod := False;
    IsPackedAccess := False;
    case TreeCodes[TreeCode].CodeClass of
      't': begin
             TypeFlags;
             Ref ('name');
             Ref ('size');
             {$ifdef EGCS}
             Ref ('size_unit');
             {$endif}
             Ref ('pointer_to');
             OptRef ('initializer');
             OptRef ('main_variant');
           end;
      'd': begin
             DeclFlags;
             Ref ('name');
             First := True;
             Str ('in ');
             Write (':', GetNumber (Pos1));
             Write (':', GetNumber (Pos1));
             Ref ('size');
             {$ifdef EGCS97}
             Ref ('size_unit');
             {$endif}
{$ifdef GCC_4_1}
             if TreeCode <> FUNCTION_DECL then
{$endif}
             Write (', align ', Number (GetNumber (Pos1), 0))
           end;
      'c': Ref ('type');
      '1',
      '2',
      '<',
      'e',
      'r': begin
             Ref ('type');
             case TreeCode of
               SAVE_EXPR,
               WITH_CLEANUP_EXPR: a := 1;
               {$ifndef EGCS97}
               CALL_EXPR:         a := 2;
               {$endif}
               {$ifndef GCC_3_4}
               METHOD_CALL_EXPR:  a := 3;
               {$endif}
               else               a := TreeCodes[TreeCode].Arguments
             end;
             for i := 1 {$ifndef GCC_3_4} + Ord (TreeCode = CONSTRUCTOR) {$endif} to a do
               Ref ('arg' + Integer2String (i));
             ClassDone := True
           end;
    end;
    case TreeCode of
      INTERFACE_NAME_NODE:
                        begin
                          Str ('interface ');
                          Str ('module ');
                          Write (', checksum ', Number (GetNumber (Pos1), 0))
                        end;
      IDENTIFIER_NODE:  begin
                          Str ('');
                          if OptStr ('spelling ') then
                            begin
                              First := True;
                              Str ('in ');
                              Write (':', GetNumber (Pos1));
                              Write (':', GetNumber (Pos1))
                            end
                        end;
      IMPORT_NODE:      begin
                          Ref ('interface');
                          OptRef ('qualifier');
                          OptRef ('filename');
                          case GetNumber (Pos1) of
                            0: Write (', import_uses');
                            1: Write (', import_qualified');
                            2: Write (', import_iso');
                            else Error (', invalid `qualified'' value')
                          end
                        end;
      TREE_LIST:        for i := 1 to GetNumber (Pos1) do
                          begin
                            if (i mod 10 = 1) and (i > 1) then
                              begin
                                WriteLn (',');
                                First := True
                              end;
                            Comma;
                            Write ('<');
                            First := True;
                            Flags;
                            if not First then Comma;
                            a := GetNumber (Pos1);
                            b := GetNumber (Pos1);
                            OutputRef (b);
                            if a <> 0 then
                              begin
                                Write (', ');
                                OutputRef (a)
                              end;
                            Write ('>');
                            First := False
                          end;
      VOID_TYPE:        OptRef ('base_type');
      REAL_TYPE,
      COMPLEX_TYPE,
      BOOLEAN_TYPE,
      CHAR_TYPE,
      INTEGER_TYPE,
      ENUMERAL_TYPE:    begin
                          OptRef ('subrange_of');
                          Ref ('min');
                          Ref ('max');
                          if TreeCode = ENUMERAL_TYPE then Ref ('values')
                        end;
      SET_TYPE:         begin
                          Ref ('element_type');
                          Ref ('domain')
                        end;
      POINTER_TYPE,
      REFERENCE_TYPE:   Ref ('target_type');
      ARRAY_TYPE:       begin
                          Ref ('element_type');
                          Ref ('domain')
                        end;
      RECORD_TYPE,
      UNION_TYPE,
      QUAL_UNION_TYPE:  begin
                          GetSize (Pos1, LangCode, SizeOf (LangCode));
                          if LangCode <> LangCodeNormal then Comma;
                          case LangCode of
                            LangCodeNormal:                 ;
                            LangCodeVariantRecord:          Write ('variant_record');
                            LangCodeNonTextFile:            Write ('file');
                            LangCodeTextFile:               Write ('text_file');
                            LangCodeObject:                 Write ('object');
                            LangCodeAbstractObject:         Write ('abstract_object');
                            LangCodeUndiscriminatedString:  Write ('undiscriminated_string');
                            LangCodePrediscriminatedString: Write ('prediscriminated_string');
                            LangCodeDiscriminatedString:    Write ('discriminated_string');
                            LangCodeUndiscriminatedSchema:  Write ('undiscriminated_schema');
                            LangCodePrediscriminatedSchema: Write ('prediscriminated_schema');
                            LangCodeDiscriminatedSchema:    Write ('discriminated_schema');
                            LangCodeFakeArray:              Write ('fake_array');
                            else                            Error ('unknown lang code')
                          end;
                          case LangCode of
                            LangCodeNonTextFile,
                            LangCodeTextFile:               begin
                                                              Ref ('element_type');
                                                              OptRef ('file_domain')
                                                            end;
                            LangCodeVariantRecord:          Ref ('variant_tag');
                            LangCodeObject,
                            LangCodeAbstractObject:         Ref ('vmt_field');
                            LangCodeUndiscriminatedString,
                            LangCodePrediscriminatedString,
                            LangCodeDiscriminatedString:    Ref ('declared_capacity');
                            LangCodeFakeArray:              Ref ('fake_array_elements');
                            else
                              if GetNumber (Pos1) <> 0 then Error ('unexpected lang_info')
                          end;
                          OptRef ('lang_base');
                          Write (', fields (');
                          First := True;
                          i := 0;
                          repeat
                            a := GetNumber (Pos1);
                            if a = 0 then Break;
                            Inc (i);
                            if (i mod 5 = 1) and (i > 1) then
                              begin
                                WriteLn (',');
                                Write ('  ');
                                First := True
                              end;
                            Comma0;
                            Write ('<');
                            OutputRef (a);
                            Write ('>');
                            First := True;
                            FieldOffset
                          until False;
                          Write (')');
                          First := False;
                          if LangCode in [LangCodeObject, LangCodeAbstractObject] then
                            begin
                              First := True;
                              i := 0;
                              Write (', methods (');
                              repeat
                                a := GetNumber (Pos1);
                                if a = 0 then Break;
                                Inc (i);
                                if (i mod 10 = 1) and (i > 1) then
                                  begin
                                    WriteLn (',');
                                    Write ('  ');
                                    First := True;
                                  end;
                                Comma0;
                                Write ('<');
                                OutputRef (a);
                                Write ('>')
                              until False;
                              Write (')');
                              First := False;
                              Ref ('vmt_var')
                            end
                        end;
      FUNCTION_TYPE:    begin
                          Ref ('result_type');
                          Ref ('arg_types');
                          First := True;
                          repeat
                            a := GetNumber (Pos1);
                            if IsSpecialNode (a, 'error_mark_node') then Break;
                            b := GetNumber (Pos1);
                            if First then Write (', attributes (');
                            Comma0;
                            Write ('<');
                            OutputRef (a);
                            Write (', ');
                            OutputRef (b);
                            Write ('>')
                          until False;
                          if not First then Write (')');
                          First := False
                        end;
      INTEGER_CST:      IntConst ('value');
      REAL_CST:         RealConst ('value');
      COMPLEX_CST:      begin
                          Ref ('re');
                          Ref ('im')
                        end;
      STRING_CST:       Str0 ('value');
      FUNCTION_DECL:    begin
                          Ref ('type');
                          Str ('linker_name ');
                          OptRef ('result_variable');
                          Write (', arguments <');
                          First := True;
                          i := 0;
                          repeat
                            a := GetNumber (Pos1);
                            if a = 0 then Break;
                            Inc (i);
                            if (i mod 10 = 1) and (i > 1) then
                              begin
                                WriteLn (',');
                                Write ('  ');
                                First := True
                              end;
                            Comma0;
                            OutputRef (a)
                          until False;
                          Write ('>');
                          First := False;
                          OptRef ('context');
                          if IsMethod then
                            OptRef ('method_decl')
                          else
                            OptRef ('operator_decl')
                        end;
      PARM_DECL:        begin
                          Ref ('type');
                          Ref ('arg_type');
                          OptRef ('context')
                        end;
      FIELD_DECL:       begin
                          Discard (OptStr ('linker_name '));
                          Ref ('type');
                          FieldOffset;
                          OptRef ('bit_field_type');
                          OptRef ('fixuplist')
                        end;
      CONST_DECL:       begin
                          Ref ('type');
                          Ref ('value')
                        end;
      LABEL_DECL,
      RESULT_DECL,
      TYPE_DECL:        Ref ('type');
      VAR_DECL:         begin
                          Ref ('type');
                          Ref ('initial');
                          Discard (OptStr ('linker_name '))
                        end;
      OPERATOR_DECL:    ;
      PLACEHOLDER_EXPR: Ref ('type');
      NON_LVALUE_EXPR:  if IsPackedAccess then Ref ('packed_info');
{$ifdef GCC_4_1}
      CONSTRUCTOR:    begin
                          var j, k : GPIInt;
                          Ref ('type');
                          k := GetNumber (Pos1);
                          for j := 1 to k do begin
                            Ref('index');
                            Ref('value')
                          end;
                        end;

{$endif}
      else              if not ClassDone 
                           {$ifndef GCC_4_0} or (TreeCode = RTL_EXPR) {$endif}
                          then Error ('unknown tree code')
    end;
    if not First then WriteLn;
    if Pos1 <= Pos2 then
      Error ('extra bytes in node');
    if Pos1 > Pos2 + 1 then
      Error ('too few bytes in node')
  end;

begin
  Reset (f, GPIFileName, 1);
  BlockRead (f, Header, SizeOf (Header));
  if Header <> GPI_HEADER then
    Error ('invalid header `' + Header + '''');
  BlockRead (f, i, SizeOf (i));
  if i = GPI_INVERSE_ENDIANNESS_MARKER then
    if BytesBigEndian then
      Error ('GPI file was created for a little endian host, but this system is big endian')
    else
      Error ('GPI file was created for a big endian host, but this system is little endian')
  else if i <> GPI_ENDIANNESS_MARKER then
    Error ('invalid endianness marker');
  WriteLn (GPIFileName, ': valid GPI file header');
  Buf := nil;
  ChunksSeen := [];
  Target := '';
  Nodes := nil;
  Offsets := nil;
  DebugKey := False;
  NodesPos1 := 0;
  NodesPos2 := 0;
  while not EOF (f) do
    begin
      BlockRead (f, ChunkCodeNum, SizeOf (ChunkCodeNum));
      BlockRead (f, ChunkLength, SizeOf (ChunkLength));
      if ChunkCodeNum > Ord (High (ChunkCode)) then
        ChunkCode := GPI_CHUNK_INVALID
      else
        ChunkCode := TChunkCode (ChunkCodeNum);
      Write ('Chunk `', Chunks[ChunkCode].Name^, '''');
      if Verbose then
        Write (' (chunk code: ', Number (ChunkCodeNum, 0),
               ', offset: ', Number (FilePos (f), 0),
               ', length: ', Number (ChunkLength, 0), ')');
      New (Buf, Max (1, ChunkLength));
      BlockRead (f, Buf^.Bytes, ChunkLength);
      if (ChunkCode in ChunksSeen) and (Chunks[ChunkCode].Unique <> 0) then
        begin
          WriteLn;
          if ChunkCode <> GPI_CHUNK_IMPLEMENTATION then
            Error ('duplicate chunk')
          { else
            Warning ('duplicate implementation chunk') }
        end;
      ChunksSeen := ChunksSeen + [ChunkCode];
      case ChunkCode of
        GPI_CHUNK_INVALID:        begin
                                    WriteLn;
                                    DumpBytes (' content:', 0, ChunkLength - 1);
                                    WriteLn
                                  end;
        GPI_CHUNK_VERSION:        begin
                                    WriteLn;
                                    DumpChars (' ', 0, ChunkLength - 1);

                                    if (ChunkLength = 0) {$ifndef GCC_4_0} or not IsSuffix (GCC_VERSION, Buf^.Chars[0 .. ChunkLength - 1]) {$endif} then
                                      begin
                                        WriteLn;
                                        Error ('backend version in GPI file does not match (rebuild GPIDump for your compiler version)')
                                      end;
                                    if Pos (' D ', Buf^.Chars[0 .. ChunkLength - 1]) <> 0 then
                                      begin
                                        Write (' (file uses debug keys)');
                                        DebugKey := True
                                      end;
                                    WriteLn
                                  end;
        GPI_CHUNK_TARGET:         begin
                                    if ChunkLength = 0 then Error ('missing target in GPI file');
                                    Target := Buf^.Chars[0 .. ChunkLength - 1];
                                    WriteLn;
                                    DumpChars (' ', 0, ChunkLength - 1);
                                    WriteLn
                                  end;
        GPI_CHUNK_MODULE_NAME,
        GPI_CHUNK_SRCFILE,
        GPI_CHUNK_LINK,
        GPI_CHUNK_LIB,
        GPI_CHUNK_INITIALIZER,
        GPI_CHUNK_GPC_MAIN_NAME:  begin
                                    WriteLn;
                                    DumpChars (' ', 0, ChunkLength - 1);
                                    WriteLn
                                  end;
        GPI_CHUNK_IMPORT:         begin
                                    WriteLn;
                                    DumpChars (' ', 0, ChunkLength - SizeOf (CheckSum) - 1);
                                    Move (Buf^.Bytes[ChunkLength - SizeOf (CheckSum)], CheckSum, SizeOf (CheckSum));
                                    WriteLn (' (checksum ', Number (CheckSum, 0), ')')
                                  end;
        GPI_CHUNK_NODES:          begin
                                    if ChunkLength <= SizeOf (CheckSum) then Error ('truncated nodes chunk');
                                    Move (Buf^.Bytes[ChunkLength - SizeOf (CheckSum)], CheckSum, SizeOf (CheckSum));
                                    WriteLn (' (contents: see below, checksum ', Number (CheckSum, 0), ')');
                                    if ComputeChecksum (Buf^.Bytes[0 .. ChunkLength - SizeOf (CheckSum) - 1]) <> CheckSum then
                                      begin
                                        WriteLn (StdErr, GPIFileName, ': checksum mismatch (GPI file corrupt)');
                                        WriteLn ('The following information may be bogus due to GPI file corruption')
                                      end;
                                    NodesPos2 := FilePos (f);
                                    NodesPos1 := NodesPos2 - ChunkLength;
                                    Nodes := Buf;
                                    Buf := nil
                                  end;
        GPI_CHUNK_OFFSETS:        begin
                                    WriteLn (' (contents: implicit in the node list below)');
                                    if ChunkLength mod SizeOf (GPIInt) <> 0 then
                                      Error ('size of offset table chunk is not a multiple of the word size');
                                    New (Offsets, Max (0, ChunkLength div SizeOf (GPIInt) - 1));
                                    Move (Buf^.Bytes[0], Offsets^[0], ChunkLength)
                                  end;
        GPI_CHUNK_IMPLEMENTATION: begin
                                    WriteLn;
                                    if ChunkLength <> 0 then
                                      Error ('implementation flag chunk contains unexpected data')
                                  end;
      end;
      Dispose (Buf)
    end;
  Close (f);
  for ChunkCode := Low (ChunkCode) to High (ChunkCode) do
    if (Chunks[ChunkCode].Required <> 0) and not (ChunkCode in ChunksSeen) then
        Error ('no ' + Chunks[ChunkCode].Name^ + ' chunk found');
  Buf := Nodes;
  i := Offsets^[Offsets^.Size];
  WriteLn ('Main node: <', Number (i, 0), '>');
  if i <> High (SpecialNodes) + Offsets^.Size - 1 then
    Error ('unexpected main node (expected ' + Number (High (SpecialNodes) + Offsets^.Size - 1, 0)
           + ') -- rebuild GPIDump for your compiler version');
  if Verbose then
    for i := 1 to High (SpecialNodes) do
      WriteLn ('<', Number (i - 1, 0), '>: ', SpecialNodes[i]^, ' (implicit)');
  for i := 0 to Offsets^.Size - 1 do
    begin
      Pos1 := Offsets^[i];
      if i = Offsets^.Size - 1 then
        Pos2 := NodesPos2 - NodesPos1 - SizeOf (CheckSum) - 1
      else
        Pos2 := Offsets^[i + 1] - 1;
      DumpNode (High (SpecialNodes) + i, Pos1, Pos2)
    end;
  WriteLn
end;

const
  LongOptions: array [1 .. 4] of OptionType =
    (('help',    NoArgument, nil, 'h'),
     ('version', NoArgument, nil, 'V'),
     ('verbose', NoArgument, nil, 'v'),
     ('hex',     NoArgument, nil, 'x'));

procedure Usage;
begin
  WriteLn ('GPI file dump for GPC ', __GPC_RELEASE__, ' based on GCC ', GCC_VERSION, '

Copyright (C) 2002-2006 Free Software Foundation, Inc.

This program is part of GPC. GPC is free software; see the source
for copying conditions. There is NO warranty; not even for
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

Usage: ', ParamStr (0), ' [options] filename...
Options:
  -h, --help     Display this help and exit
  -V, --version  Output version information and exit
  -v, --verbose  Produce more verbose output
  -x, --hex      Output numbers in hexadecimal')
end;

var
  i: Integer;
  ch: Char;

begin
  Verbose := False;
  Hex := False;
  repeat
    ch := GetOptLong ('', LongOptions, Null, False);
    case ch of
      UnknownOption: begin
                       WriteLn (StdErr);
                       Usage;
                       Halt (1)
                     end;
      'h': begin
             Usage;
             Halt
           end;
      'V': begin
             WriteLn ('gpidump for GPC ', __GPC_RELEASE__, ' based on GCC ', GCC_VERSION);
             WriteLn ('Copyright (C) 2002-2006 Free Software Foundation, Inc.');
             WriteLn ('Report bugs to <gpc@gnu.de>.');
             Halt
           end;
      'v': Verbose := True;
      'x': Hex := True;
    end
  until ch = EndOfOptions;
  if ParamCount < FirstNonOption then
    begin
      Usage;
      Halt (1)
    end;
  for i := FirstNonOption to ParamCount do ProcessFile (ParamStr (i))
end.
