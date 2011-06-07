{ GPC demo program about BP compatible procedural variables
  (including parameters), Standard Pascal procedural parameters, and
  procedure pointers (variables and parameters), a GPC extension.

  Copyright (C) 1999-2006 Free Software Foundation, Inc.

  Author: Frank Heckenbach <frank@pascal.gnu.de>

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License as
  published by the Free Software Foundation, version 2.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; see the file COPYING. If not, write to
  the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
  Boston, MA 02111-1307, USA.

  As a special exception, if you incorporate even large parts of the
  code of this demo program into another program with substantially
  different functionality, this does not cause the other program to
  be covered by the GNU General Public License. This exception does
  not however invalidate any other reasons why it might be covered
  by the GNU General Public License. }

program ProcVarDemo;

{ A demo procedure }
procedure Foo (a: Integer);
begin
  WriteLn ('Foo ', a)
end;

type
  BPProcType = procedure (a: Integer);   { BP compatible }
  GPCProcPtr = ^procedure (a: Integer);  { GPC extension }

var
  BPProcVar: BPProcType;
  BPProcVarAsPointer: Pointer absolute BPProcVar;
  GPCProcPtrVar: GPCProcPtr;
  GPCProcPtrVarAsPointer: Pointer absolute GPCProcPtrVar;

procedure SPProcPar (procedure Proc (a: Integer));
begin
  Proc (3)
end;

procedure BPProcPar (Proc: BPProcType);
begin
  Proc (4)
end;

procedure GPCProcPar (Proc: GPCProcPtr);
begin
  Proc^ (5)
end;

begin
  WriteLn ('The output of this demo is not very meaningful.');
  WriteLn ('Please read the comments in the source code.');

  { Procedural variables. GPC supports BP compatible procedural
    variables as well as procedure pointers as an extension. All
    that's said here applies to procedures and functions with any
    number and types of arguments, of course. }

  { BP compatible }
  { Assigning them and calling them works without any `@' or `^' and
    may therefore seem easier ... }
  BPProcVar := Foo;
  BPProcVar (1);
  { ... however, when you have to compare them to pointers, or need
    the address of the variable itself, you need an extra `@' which
    makes for some rather strange syntax ... }
  WriteLn (@BPProcVar <> nil);
  WriteLn (@BPProcVar = BPProcVarAsPointer);
  WriteLn (Pointer (@@BPProcVar) = Pointer (@BPProcVarAsPointer));

  { GPC extension }
  { Procedure pointers. They can be assigned with `@' and used with
    `^' like regular pointers. }
  GPCProcPtrVar := @Foo;
  GPCProcPtrVar^ (2);
  { Therefore, comparing them to other pointers and taking the
    address of them is straightforward. }
  WriteLn (GPCProcPtrVar <> nil);
  WriteLn (GPCProcPtrVar = GPCProcPtrVarAsPointer);
  WriteLn (Pointer (@GPCProcPtrVar) = Pointer (@GPCProcPtrVarAsPointer));

  { Procedural parameters. Standard Pascal defines a way to declare
    them. BP does *not* support this, but instead allows its
    procedural variables to be used as parameters. GPC supports both
    as well as procedure pointers used as parameters. }

  { Standard Pascal }
  { The type of the procedural parameters is declared within the
    called procedure. }
  SPProcPar (Foo);

  { Borland Pascal }
  { Using the declared procedural type as a parameter. }
  BPProcPar (Foo);

  { GPC extension }
  { Using the declared procedure pointer type as a parameter. }
  GPCProcPar (@Foo)
end.
