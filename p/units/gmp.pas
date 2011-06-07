{ Definitions for GNU multiple precision functions: arithmetic with
  integer, rational and real numbers of arbitrary size and
  precision.

  Translation of the C header (gmp.h) of the GMP library. Tested
  with GMP 3.x and 4.x.

  To use the GMP unit, you will need the GMP library which can be
  found in http://www.gnu-pascal.de/libs/

  Copyright (C) 1998-2006 Free Software Foundation, Inc.

  Author: Frank Heckenbach <frank@pascal.gnu.de>

  This file is part of GNU Pascal.

  GNU Pascal is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published
  by the Free Software Foundation; either version 3, or (at your
  option) any later version.

  GNU Pascal is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with GNU Pascal; see the file COPYING. If not, write to the
  Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
  02111-1307, USA.

  As a special exception, if you link this file with files compiled
  with a GNU compiler to produce an executable, this does not cause
  the resulting executable to be covered by the GNU General Public
  License. This exception does not however invalidate any other
  reasons why the executable file might be covered by the GNU
  General Public License.

  Please also note the license of the GMP library. }

{$gnu-pascal,I-}
{$if __GPC_RELEASE__ < 20030303}
{$error This unit requires GPC release 20030303 or newer.}
{$endif}
{$nested-comments}

{ If HAVE_GMP4 is set (the default unless HAVE_GMP3 is set, some
  interface changes made in GMP 4 are taken into account.
  I.e., if this is set wrong, programs might fail. However, this
  only affects a few routines related to random numbers. }
{$if not defined (HAVE_GMP3)}
{$define HAVE_GMP4}
{$endif}

{$undef GMP}  { in case it's set by the user }
unit GMP;

interface

uses GPC;

{$if defined (__mips) and defined (_ABIN32) and defined (HAVE_GMP3)}
{ Force the use of 64-bit limbs for all 64-bit MIPS CPUs if ABI
  permits. }
{$define _LONG_LONG_LIMB}
{$endif}

type
  {$ifdef _SHORT_LIMB}
  mp_limb_t        = CCardinal;
  mp_limb_signed_t = CInteger;
  {$elif defined (_LONG_LONG_LIMB)}
  mp_limb_t        = LongCard;
  mp_limb_signed_t = LongInt;
  {$else}
  mp_limb_t        = MedCard;
  mp_limb_signed_t = MedInt;
  {$endif}

  mp_ptr           = ^mp_limb_t;

  {$if defined (_CRAY) and not defined (_CRAYMPP)}
  mp_size_t        = CInteger;
  mp_exp_t         = CInteger;
  {$else}
  mp_size_t        = MedInt;
  mp_exp_t         = MedInt;
  {$endif}

  mpz_t = record
    mp_alloc,
    mp_size: CInteger;
    mp_d:    mp_ptr
  end;

  mpz_array_ptr = ^mpz_array;
  mpz_array = array [0 .. MaxVarSize div SizeOf (mpz_t) - 1] of mpz_t;

  mpq_t = record
    mp_num,
    mp_den: mpz_t
  end;

  mpf_t = record
    mp_prec,
    mp_size: CInteger;
    mp_exp:  mp_exp_t;
    mp_d:    mp_ptr
  end;

  TAllocFunction    = function (Size: SizeType): Pointer;
  TReAllocFunction  = function (var Dest: Pointer; OldSize, NewSize: SizeType): Pointer;
  TDeAllocProcedure = procedure (Src: Pointer; Size: SizeType);

var
  mp_bits_per_limb: CInteger; attribute (const); external name '__gmp_bits_per_limb';

procedure mp_set_memory_functions (AllocFunction: TAllocFunction;
                                   ReAllocFunction: TReAllocFunction;
                                   DeAllocProcedure: TDeAllocProcedure); external name '__gmp_set_memory_functions';

{ Integer (i.e. Z) routines }

procedure mpz_init             (var Dest: mpz_t);                                                                              external name '__gmpz_init';
procedure mpz_clear            (var Dest: mpz_t);                                                                              external name '__gmpz_clear';
function  mpz_realloc          (var Dest: mpz_t; NewAlloc: mp_size_t): Pointer;                                                external name '__gmpz_realloc';
procedure mpz_array_init       (Dest: mpz_array_ptr; ArraySize, FixedNumBits: mp_size_t);                                      external name '__gmpz_array_init';

procedure mpz_set              (var Dest: mpz_t; protected var Src: mpz_t);                                                    external name '__gmpz_set';
procedure mpz_set_ui           (var Dest: mpz_t; Src: MedCard);                                                                external name '__gmpz_set_ui';
procedure mpz_set_si           (var Dest: mpz_t; Src: MedInt);                                                                 external name '__gmpz_set_si';
procedure mpz_set_d            (var Dest: mpz_t; Src: Real);                                                                   external name '__gmpz_set_d';
procedure mpz_set_q            (var Dest: mpz_t; Src: mpq_t);                                                                  external name '__gmpz_set_q';
procedure mpz_set_f            (var Dest: mpz_t; Src: mpf_t);                                                                  external name '__gmpz_set_f';
function  mpz_set_str          (var Dest: mpz_t; Src: CString; Base: CInteger): CInteger;                                      external name '__gmpz_set_str';

procedure mpz_init_set         (var Dest: mpz_t; protected var Src: mpz_t);                                                    external name '__gmpz_init_set';
procedure mpz_init_set_ui      (var Dest: mpz_t; Src: MedCard);                                                                external name '__gmpz_init_set_ui';
procedure mpz_init_set_si      (var Dest: mpz_t; Src: MedInt);                                                                 external name '__gmpz_init_set_si';
procedure mpz_init_set_d       (var Dest: mpz_t; Src: Real);                                                                   external name '__gmpz_init_set_d';
function  mpz_init_set_str     (var Dest: mpz_t; Src: CString; Base: CInteger): CInteger;                                      external name '__gmpz_init_set_str';

function  mpz_get_ui           (protected var Src: mpz_t): MedCard;                                                            external name '__gmpz_get_ui';
function  mpz_get_si           (protected var Src: mpz_t): MedInt;                                                             external name '__gmpz_get_si';
function  mpz_get_d            (protected var Src: mpz_t): Real;                                                               external name '__gmpz_get_d';
{ Pass nil for Dest to let the function allocate memory for it }
function  mpz_get_str          (Dest: CString; Base: CInteger; protected var Src: mpz_t): CString;                             external name '__gmpz_get_str';

procedure mpz_add              (var Dest: mpz_t; protected var Src1, Src2: mpz_t);                                             external name '__gmpz_add';
procedure mpz_add_ui           (var Dest: mpz_t; protected var Src1: mpz_t; Src2: MedCard);                                    external name '__gmpz_add_ui';
procedure mpz_sub              (var Dest: mpz_t; protected var Src1, Src2: mpz_t);                                             external name '__gmpz_sub';
procedure mpz_sub_ui           (var Dest: mpz_t; protected var Src1: mpz_t; Src2: MedCard);                                    external name '__gmpz_sub_ui';
procedure mpz_mul              (var Dest: mpz_t; protected var Src1, Src2: mpz_t);                                             external name '__gmpz_mul';
procedure mpz_mul_ui           (var Dest: mpz_t; protected var Src1: mpz_t; Src2: MedCard);                                    external name '__gmpz_mul_ui';
procedure mpz_mul_2exp         (var Dest: mpz_t; protected var Src1: mpz_t; Src2: MedCard);                                    external name '__gmpz_mul_2exp';
procedure mpz_neg              (var Dest: mpz_t; protected var Src: mpz_t);                                                    external name '__gmpz_neg';
procedure mpz_abs              (var Dest: mpz_t; protected var Src: mpz_t);                                                    external name '__gmpz_abs';
procedure mpz_fac_ui           (var Dest: mpz_t; Src: MedCard);                                                                external name '__gmpz_fac_ui';

procedure mpz_tdiv_q           (var Dest: mpz_t; protected var Src1, Src2: mpz_t);                                             external name '__gmpz_tdiv_q';
procedure mpz_tdiv_q_ui        (var Dest: mpz_t; protected var Src1: mpz_t; Src2: MedCard);                                    external name '__gmpz_tdiv_q_ui';
procedure mpz_tdiv_r           (var Dest: mpz_t; protected var Src1, Src2: mpz_t);                                             external name '__gmpz_tdiv_r';
procedure mpz_tdiv_r_ui        (var Dest: mpz_t; protected var Src1: mpz_t; Src2: MedCard);                                    external name '__gmpz_tdiv_r_ui';
procedure mpz_tdiv_qr          (var DestQ, DestR: mpz_t; protected var Src1, Src2: mpz_t);                                     external name '__gmpz_tdiv_qr';
procedure mpz_tdiv_qr_ui       (var DestQ, DestR: mpz_t; protected var Src1: mpz_t; Src2: MedCard);                            external name '__gmpz_tdiv_qr_ui';

procedure mpz_fdiv_q           (var Dest: mpz_t; protected var Src1, Src2: mpz_t);                                             external name '__gmpz_fdiv_q';
function  mpz_fdiv_q_ui        (var Dest: mpz_t; protected var Src1: mpz_t; Src2: MedCard): MedCard;                           external name '__gmpz_fdiv_q_ui';
procedure mpz_fdiv_r           (var Dest: mpz_t; protected var Src1, Src2: mpz_t);                                             external name '__gmpz_fdiv_r';
function  mpz_fdiv_r_ui        (var Dest: mpz_t; protected var Src1: mpz_t; Src2: MedCard): MedCard;                           external name '__gmpz_fdiv_r_ui';
procedure mpz_fdiv_qr          (var DestQ, DestR: mpz_t; protected var Src1, Src2: mpz_t);                                     external name '__gmpz_fdiv_qr';
function  mpz_fdiv_qr_ui       (var DestQ, DestR: mpz_t; protected var Src1: mpz_t; Src2: MedCard): MedCard;                   external name '__gmpz_fdiv_qr_ui';
function  mpz_fdiv_ui          (protected var Src1: mpz_t; Src2: MedCard): MedCard;                                            external name '__gmpz_fdiv_ui';

procedure mpz_cdiv_q           (var Dest: mpz_t; protected var Src1, Src2: mpz_t);                                             external name '__gmpz_cdiv_q';
function  mpz_cdiv_q_ui        (var Dest: mpz_t; protected var Src1: mpz_t; Src2: MedCard): MedCard;                           external name '__gmpz_cdiv_q_ui';
procedure mpz_cdiv_r           (var Dest: mpz_t; protected var Src1, Src2: mpz_t);                                             external name '__gmpz_cdiv_r';
function  mpz_cdiv_r_ui        (var Dest: mpz_t; protected var Src1: mpz_t; Src2: MedCard): MedCard;                           external name '__gmpz_cdiv_r_ui';
procedure mpz_cdiv_qr          (var DestQ, DestR: mpz_t; protected var Src1,Src2: mpz_t);                                      external name '__gmpz_cdiv_qr';
function  mpz_cdiv_qr_ui       (var DestQ, DestR: mpz_t; protected var Src1: mpz_t; Src2: MedCard): MedCard;                   external name '__gmpz_cdiv_qr_ui';
function  mpz_cdiv_ui          (protected var Src1: mpz_t; Src2:MedCard): MedCard;                                             external name '__gmpz_cdiv_ui';

procedure mpz_mod              (var Dest: mpz_t; protected var Src1,Src2: mpz_t);                                              external name '__gmpz_mod';
procedure mpz_divexact         (var Dest: mpz_t; protected var Src1,Src2: mpz_t);                                              external name '__gmpz_divexact';

procedure mpz_tdiv_q_2exp      (var Dest: mpz_t; protected var Src1: mpz_t; Src2: MedCard);                                    external name '__gmpz_tdiv_q_2exp';
procedure mpz_tdiv_r_2exp      (var Dest: mpz_t; protected var Src1: mpz_t; Src2: MedCard);                                    external name '__gmpz_tdiv_r_2exp';
procedure mpz_fdiv_q_2exp      (var Dest: mpz_t; protected var Src1: mpz_t; Src2: MedCard);                                    external name '__gmpz_fdiv_q_2exp';
procedure mpz_fdiv_r_2exp      (var Dest: mpz_t; protected var Src1: mpz_t; Src2: MedCard);                                    external name '__gmpz_fdiv_r_2exp';

procedure mpz_powm             (var Dest: mpz_t; protected var Base, Exponent, Modulus: mpz_t);                                external name '__gmpz_powm';
procedure mpz_powm_ui          (var Dest: mpz_t; protected var Base: mpz_t; Exponent: MedCard; protected var Modulus: mpz_t);  external name '__gmpz_powm_ui';
procedure mpz_pow_ui           (var Dest: mpz_t; protected var Base: mpz_t; Exponent: MedCard);                                external name '__gmpz_pow_ui';
procedure mpz_ui_pow_ui        (var Dest: mpz_t; Base, Exponent: MedCard);                                                     external name '__gmpz_ui_pow_ui';

procedure mpz_sqrt             (var Dest: mpz_t; protected var Src: mpz_t);                                                    external name '__gmpz_sqrt';
procedure mpz_sqrtrem          (var Dest, DestR: mpz_t; protected var Src: mpz_t);                                             external name '__gmpz_sqrtrem';
function  mpz_perfect_square_p (protected var Src: mpz_t): CInteger;                                                           external name '__gmpz_perfect_square_p';

function  mpz_probab_prime_p   (protected var Src: mpz_t; Repetitions: CInteger): CInteger;                                    external name '__gmpz_probab_prime_p';
procedure mpz_gcd              (var Dest: mpz_t; protected var Src1, Src2: mpz_t);                                             external name '__gmpz_gcd';
function  mpz_gcd_ui           (var Dest: mpz_t; protected var Src1: mpz_t; Src2: MedCard): MedCard;                           external name '__gmpz_gcd_ui';
procedure mpz_gcdext           (var Dest, DestA, DestB: mpz_t; protected var SrcA, SrcB: mpz_t);                               external name '__gmpz_gcdext';
function  mpz_invert           (var Dest: mpz_t; protected var Src, Modulus: mpz_t): CInteger;                                 external name '__gmpz_invert';
function  mpz_jacobi           (protected var Src1, Src2: mpz_t): CInteger;                                                    external name '__gmpz_jacobi';

function  mpz_cmp              (protected var Src1, Src2: mpz_t): CInteger;                                                    external name '__gmpz_cmp';
function  mpz_cmp_ui           (protected var Src1: mpz_t; Src2: MedCard): CInteger;                                           external name '__gmpz_cmp_ui';
function  mpz_cmp_si           (protected var Src1: mpz_t; Src2: MedInt): CInteger;                                            external name '__gmpz_cmp_si';
function  mpz_sgn              (protected var Src: mpz_t): CInteger;                                                           attribute (inline);

procedure mpz_and              (var Dest: mpz_t; protected var Src1, Src2: mpz_t);                                             external name '__gmpz_and';
procedure mpz_ior              (var Dest: mpz_t; protected var Src1, Src2: mpz_t);                                             external name '__gmpz_ior';
procedure mpz_com              (var Dest: mpz_t; protected var Src: mpz_t);                                                    external name '__gmpz_com';
function  mpz_popcount         (protected var Src: mpz_t): MedCard;                                                            external name '__gmpz_popcount';
function  mpz_hamdist          (protected var Src1, Src2: mpz_t): MedCard;                                                     external name '__gmpz_hamdist';
function  mpz_scan0            (protected var Src: mpz_t; StartingBit: MedCard): MedCard;                                      external name '__gmpz_scan0';
function  mpz_scan1            (protected var Src: mpz_t; StartingBit: MedCard): MedCard;                                      external name '__gmpz_scan1';
procedure mpz_setbit           (var Dest: mpz_t; BitIndex: MedCard);                                                           external name '__gmpz_setbit';
procedure mpz_clrbit           (var Dest: mpz_t; BitIndex: MedCard);                                                           external name '__gmpz_clrbit';

procedure mpz_random           (var Dest: mpz_t; MaxSize: mp_size_t);                                                          external name '__gmpz_random';
procedure mpz_random2          (var Dest: mpz_t; MaxSize: mp_size_t);                                                          external name '__gmpz_random2';
function  mpz_sizeinbase       (protected var Src: mpz_t; Base: CInteger): SizeType;                                           external name '__gmpz_sizeinbase';

{ Rational (i.e. Q) routines }

procedure mpq_canonicalize     (var Dest: mpq_t);                                                                              external name '__gmpq_canonicalize';

procedure mpq_init             (var Dest: mpq_t);                                                                              external name '__gmpq_init';
procedure mpq_clear            (var Dest: mpq_t);                                                                              external name '__gmpq_clear';
procedure mpq_set              (var Dest: mpq_t; protected var Src: mpq_t);                                                    external name '__gmpq_set';
procedure mpq_set_z            (var Dest: mpq_t; protected var Src: mpz_t);                                                    external name '__gmpq_set_z';
procedure mpq_set_ui           (var Dest: mpq_t; Nom, Den: MedCard);                                                           external name '__gmpq_set_ui';
procedure mpq_set_si           (var Dest: mpq_t; Nom: MedInt; Den: MedCard);                                                   external name '__gmpq_set_si';

procedure mpq_add              (var Dest: mpq_t; protected var Src1, Src2: mpq_t);                                             external name '__gmpq_add';
procedure mpq_sub              (var Dest: mpq_t; protected var Src1, Src2: mpq_t);                                             external name '__gmpq_sub';
procedure mpq_mul              (var Dest: mpq_t; protected var Src1, Src2: mpq_t);                                             external name '__gmpq_mul';
procedure mpq_div              (var Dest: mpq_t; protected var Src1, Src2: mpq_t);                                             external name '__gmpq_div';
procedure mpq_neg              (var Dest: mpq_t; protected var Src: mpq_t);                                                    external name '__gmpq_neg';
procedure mpq_inv              (var Dest: mpq_t; protected var Src: mpq_t);                                                    external name '__gmpq_inv';

function  mpq_cmp              (protected var Src1, Src2: mpq_t): CInteger;                                                    external name '__gmpq_cmp';
function  mpq_cmp_ui           (protected var Src1: mpq_t; Nom2, Den2: MedCard): CInteger;                                     external name '__gmpq_cmp_ui';
function  mpq_sgn              (protected var Src: mpq_t): CInteger;                                                           attribute (inline);
function  mpq_equal            (protected var Src1, Src2: mpq_t): CInteger;                                                    external name '__gmpq_equal';

function  mpq_get_d            (protected var Src: mpq_t): Real;                                                               external name '__gmpq_get_d';
procedure mpq_set_num          (var Dest: mpq_t; protected var Src: mpz_t);                                                    external name '__gmpq_set_num';
procedure mpq_set_den          (var Dest: mpq_t; protected var Src: mpz_t);                                                    external name '__gmpq_set_den';
procedure mpq_get_num          (var Dest: mpz_t; protected var Src: mpq_t);                                                    external name '__gmpq_get_num';
procedure mpq_get_den          (var Dest: mpz_t; protected var Src: mpq_t);                                                    external name '__gmpq_get_den';

{ Floating point (i.e. R) routines }

procedure mpf_set_default_prec (Precision: MedCard);                                                                           external name '__gmpf_set_default_prec';
procedure mpf_init             (var Dest: mpf_t);                                                                              external name '__gmpf_init';
procedure mpf_init2            (var Dest: mpf_t; Precision: MedCard);                                                          external name '__gmpf_init2';
procedure mpf_clear            (var Dest: mpf_t);                                                                              external name '__gmpf_clear';
procedure mpf_set_prec         (var Dest: mpf_t; Precision: MedCard);                                                          external name '__gmpf_set_prec';
function  mpf_get_prec         (protected var Src: mpf_t): MedCard;                                                            external name '__gmpf_get_prec';
procedure mpf_set_prec_raw     (var Dest: mpf_t; Precision: MedCard);                                                          external name '__gmpf_set_prec_raw';

procedure mpf_set              (var Dest: mpf_t; protected var Src: mpf_t);                                                    external name '__gmpf_set';
procedure mpf_set_ui           (var Dest: mpf_t; Src: MedCard);                                                                external name '__gmpf_set_ui';
procedure mpf_set_si           (var Dest: mpf_t; Src: MedInt);                                                                 external name '__gmpf_set_si';
procedure mpf_set_d            (var Dest: mpf_t; Src: Real);                                                                   external name '__gmpf_set_d';
procedure mpf_set_z            (var Dest: mpf_t; protected var Src: mpz_t);                                                    external name '__gmpf_set_z';
procedure mpf_set_q            (var Dest: mpf_t; protected var Src: mpq_t);                                                    external name '__gmpf_set_q';
function  mpf_set_str          (var Dest: mpf_t; Src: CString; Base: CInteger): CInteger;                                      external name '__gmpf_set_str';

procedure mpf_init_set         (var Dest: mpf_t; protected var Src: mpf_t);                                                    external name '__gmpf_init_set';
procedure mpf_init_set_ui      (var Dest: mpf_t; Src: MedCard);                                                                external name '__gmpf_init_set_ui';
procedure mpf_init_set_si      (var Dest: mpf_t; Src: MedInt);                                                                 external name '__gmpf_init_set_si';
procedure mpf_init_set_d       (var Dest: mpf_t; Src: Real);                                                                   external name '__gmpf_init_set_d';
function  mpf_init_set_str     (var Dest: mpf_t; Src: CString; Base: CInteger): CInteger;                                      external name '__gmpf_init_set_str';

function  mpf_get_d            (protected var Src: mpf_t): Real;                                                               external name '__gmpf_get_d';
{ Pass nil for Dest to let the function allocate memory for it }
function  mpf_get_str          (Dest: CString; var Exponent: mp_exp_t; Base: CInteger;
                                NumberOfDigits: SizeType; protected var Src: mpf_t): CString;                                  external name '__gmpf_get_str';

procedure mpf_add              (var Dest: mpf_t; protected var Src1, Src2: mpf_t);                                             external name '__gmpf_add';
procedure mpf_add_ui           (var Dest: mpf_t; protected var Src1: mpf_t; Src2: MedCard);                                    external name '__gmpf_add_ui';
procedure mpf_sub              (var Dest: mpf_t; protected var Src1, Src2: mpf_t);                                             external name '__gmpf_sub';
procedure mpf_ui_sub           (var Dest: mpf_t; Src1: MedCard; protected var Src2: mpf_t);                                    external name '__gmpf_ui_sub';
procedure mpf_sub_ui           (var Dest: mpf_t; protected var Src1: mpf_t; Src2: MedCard);                                    external name '__gmpf_sub_ui';
procedure mpf_mul              (var Dest: mpf_t; protected var Src1, Src2: mpf_t);                                             external name '__gmpf_mul';
procedure mpf_mul_ui           (var Dest: mpf_t; protected var Src1: mpf_t; Src2: MedCard);                                    external name '__gmpf_mul_ui';
procedure mpf_div              (var Dest: mpf_t; protected var Src1, Src2: mpf_t);                                             external name '__gmpf_div';
procedure mpf_ui_div           (var Dest: mpf_t; Src1: MedCard; protected var Src2: mpf_t);                                    external name '__gmpf_ui_div';
procedure mpf_div_ui           (var Dest: mpf_t; protected var Src1: mpf_t; Src2: MedCard);                                    external name '__gmpf_div_ui';
procedure mpf_sqrt             (var Dest: mpf_t; protected var Src: mpf_t);                                                    external name '__gmpf_sqrt';
procedure mpf_sqrt_ui          (var Dest: mpf_t; Src: MedCard);                                                                external name '__gmpf_sqrt_ui';
procedure mpf_neg              (var Dest: mpf_t; protected var Src: mpf_t);                                                    external name '__gmpf_neg';
procedure mpf_abs              (var Dest: mpf_t; protected var Src: mpf_t);                                                    external name '__gmpf_abs';
procedure mpf_mul_2exp         (var Dest: mpf_t; protected var Src1: mpf_t; Src2: MedCard);                                    external name '__gmpf_mul_2exp';
procedure mpf_div_2exp         (var Dest: mpf_t; protected var Src1: mpf_t; Src2: MedCard);                                    external name '__gmpf_div_2exp';

function  mpf_cmp              (protected var Src1, Src2: mpf_t): CInteger;                                                    external name '__gmpf_cmp';
function  mpf_cmp_si           (protected var Src1: mpf_t; Src2: MedInt): CInteger;                                            external name '__gmpf_cmp_si';
function  mpf_cmp_ui           (protected var Src1: mpf_t; Src2: MedCard): CInteger;                                           external name '__gmpf_cmp_ui';
function  mpf_eq               (protected var Src1, Src2: mpf_t; NumberOfBits: MedCard): CInteger;                             external name '__gmpf_eq';
procedure mpf_reldiff          (var Dest: mpf_t; protected var Src1, Src2: mpf_t);                                             external name '__gmpf_reldiff';
function  mpf_sgn              (protected var Src: mpf_t): CInteger;                                                           attribute (inline);

procedure mpf_random2          (var Dest: mpf_t; MaxSize: mp_size_t; MaxExp: mp_exp_t);                                        external name '__gmpf_random2';

{$if False}  { @@ commented out because they use C file pointers }
function  mpz_inp_str          (var Dest: mpz_t; Src: CFilePtr; Base: CInteger): SizeType;                                     external name '__gmpz_inp_str';
function  mpz_inp_raw          (var Dest: mpz_t; Src: CFilePtr): SizeType;                                                     external name '__gmpz_inp_raw';
function  mpz_out_str          (Dest: CFilePtr; Base: CInteger; protected var Src: mpz_t): SizeType;                           external name '__gmpz_out_str';
function  mpz_out_raw          (Dest: CFilePtr; protected var Src: mpz_t): SizeType ;                                          external name '__gmpz_out_raw';
{ @@ mpf_out_str has a bug in GMP 2.0.2: it writes a spurious #0 before the exponent for negative numbers }
function  mpf_out_str          (Dest: CFilePtr; Base: CInteger; NumberOfDigits: SizeType; protected var Src: mpf_t): SizeType; external name '__gmpf_out_str';
function  mpf_inp_str          (var Dest: mpf_t; Src: CFilePtr; Base: CInteger): SizeType;                                     external name '__gmpf_inp_str';
{$endif}

{ Available random number generation algorithms. }
type
  gmp_randalg_t = (GMPRandAlgLC { Linear congruential. });

const
  GMPRandAlgDefault = GMPRandAlgLC;

{ Linear congruential data struct. }
type
  gmp_randata_lc = record
    a: mpz_t;  { Multiplier. }
    c: MedCard;  { Adder. }
    m: mpz_t;  { Modulus (valid only if M2Exp = 0). }
    M2Exp: MedCard;  { If <> 0, modulus is 2 ^ M2Exp. }
  end;

type
  gmp_randstate_t = record
    Seed: mpz_t;  { Current seed. }
    Alg: gmp_randalg_t;  { Algorithm used. }
    AlgData: record  { Algorithm specific data. }
    case gmp_randalg_t of
      GMPRandAlgLC: (lc: ^gmp_randata_lc)  { Linear congruential. }
    end
  end;

procedure gmp_randinit         (var State: gmp_randstate_t; Alg: gmp_randalg_t; ...);                                         external name '__gmp_randinit';
procedure gmp_randinit_lc      (var State: gmp_randstate_t; {$ifdef HAVE_GMP4} protected var {$endif} a: mpz_t; c: MedCard; {$ifdef HAVE_GMP4} protected var {$endif} m: mpz_t); external name '__gmp_randinit_lc';
procedure gmp_randinit_lc_2exp (var State: gmp_randstate_t; {$ifdef HAVE_GMP4} protected var {$endif} a: mpz_t; c: MedCard; M2Exp: MedCard); external name '__gmp_randinit_lc_2exp';
procedure gmp_randseed         (var State: gmp_randstate_t; Seed: mpz_t);                                                     external name '__gmp_randseed';
procedure gmp_randseed_ui      (var State: gmp_randstate_t; Seed: MedCard);                                                   external name '__gmp_randseed_ui';
procedure gmp_randclear        (var State: gmp_randstate_t);                                                                  external name '__gmp_randclear';

procedure mpz_addmul_ui        (var Dest: mpz_t; protected var Src1: mpz_t; Src2: MedCard);                                   external name '__gmpz_addmul_ui';
procedure mpz_bin_ui           (var Dest: mpz_t; protected var Src1: mpz_t; Src2: MedCard);                                   external name '__gmpz_bin_ui';
procedure mpz_bin_uiui         (var Dest: mpz_t; Src1, Src2: MedCard);                                                        external name '__gmpz_bin_uiui';
function  mpz_cmpabs           (protected var Src1, Src2: mpz_t): CInteger;                                                   external name '__gmpz_cmpabs';
function  mpz_cmpabs_ui        (protected var Src1: mpz_t; Src2: MedCard): CInteger;                                          external name '__gmpz_cmpabs_ui';
procedure mpz_dump             (protected var Src: mpz_t);                                                                    external name '__gmpz_dump';
procedure mpz_fib_ui           (var Dest: mpz_t; Src: MedCard);                                                               external name '__gmpz_fib_ui';
function  mpz_fits_sint_p      (protected var Src: mpz_t): CInteger;                                                          external name '__gmpz_fits_sint_p';
function  mpz_fits_slong_p     (protected var Src: mpz_t): CInteger;                                                          external name '__gmpz_fits_slong_p';
function  mpz_fits_sshort_p    (protected var Src: mpz_t): CInteger;                                                          external name '__gmpz_fits_sshort_p';
function  mpz_fits_uint_p      (protected var Src: mpz_t): CInteger;                                                          external name '__gmpz_fits_uint_p';
function  mpz_fits_ulong_p     (protected var Src: mpz_t): CInteger;                                                          external name '__gmpz_fits_ulong_p';
function  mpz_fits_ushort_p    (protected var Src: mpz_t): CInteger;                                                          external name '__gmpz_fits_ushort_p';
procedure mpz_lcm              (var Dest: mpz_t; protected var Src1, Src2: mpz_t);                                            external name '__gmpz_lcm';
procedure mpz_nextprime        (var Dest: mpz_t; protected var Src: mpz_t);                                                   external name '__gmpz_nextprime';
function  mpz_perfect_power_p  (protected var Src: mpz_t): CInteger;                                                          external name '__gmpz_perfect_power_p';
function  mpz_remove           (var Dest: mpz_t; protected var Src1, Src2: mpz_t): MedCard;                                   external name '__gmpz_remove';
function  mpz_root             (var Dest: mpz_t; protected var Src: mpz_t; n: MedCard): CInteger;                             external name '__gmpz_root';
procedure mpz_rrandomb         (var ROP: mpz_t; var State: gmp_randstate_t; n: MedCard);                                      external name '__gmpz_rrandomb';
procedure mpz_swap             (var v1, v2: mpz_t);                                                                           external name '__gmpz_swap';
function  mpz_tdiv_ui          (protected var Src1: mpz_t; Src2: MedCard): MedCard;                                           external name '__gmpz_tdiv_ui';
function  mpz_tstbit           (protected var Src1: mpz_t; Src2: MedCard): CInteger;                                          external name '__gmpz_tstbit';
procedure mpz_urandomb         ({$ifdef HAVE_GMP4} var {$endif} ROP: mpz_t; var State: gmp_randstate_t; n: MedCard);          external name '__gmpz_urandomb';
procedure mpz_urandomm         ({$ifdef HAVE_GMP4} var {$endif} ROP: mpz_t; var State: gmp_randstate_t; {$ifdef HAVE_GMP4} protected var {$endif} n: mpz_t); external name '__gmpz_urandomm';
procedure mpz_xor              (var Dest: mpz_t; protected var Src1, Src2: mpz_t);                                            external name '__gmpz_xor';

procedure mpq_set_d            (var Dest: mpq_t; Src: Real);                                                                  external name '__gmpq_set_d';

procedure mpf_ceil             (var Dest: mpf_t; protected var Src: mpf_t);                                                   external name '__gmpf_ceil';
procedure mpf_floor            (var Dest: mpf_t; protected var Src: mpf_t);                                                   external name '__gmpf_floor';
{$ifdef HAVE_GMP4}
function  mpf_get_si           (protected var Src: mpf_t): MedInt;                                                            external name '__gmpf_get_si';
function  mpf_get_ui           (protected var Src: mpf_t): MedCard;                                                           external name '__gmpf_get_ui';
function  mpf_get_d_2exp       (var Exp: MedInt; protected var Src: mpf_t): Real;                                             external name '__gmpf_get_d_2exp';
{$endif}
procedure mpf_pow_ui           (var Dest: mpf_t; protected var Src1: mpf_t; Src2: MedCard);                                   external name '__gmpf_pow_ui';
procedure mpf_trunc            (var Dest: mpf_t; protected var Src: mpf_t);                                                   external name '__gmpf_trunc';
procedure mpf_urandomb         (ROP: mpf_t; var State: gmp_randstate_t; n: MedCard);                                          external name '__gmpf_urandomb';

const
  GMPErrorNone = 0;
  GMPErrorUnsupportedArgument = 1;
  GMPErrorDivisionByZero = 2;
  GMPErrorSqrtOfNegative = 4;
  GMPErrorInvalidArgument = 8;
  GMPErrorAllocate = 16;

var
  gmp_errno: CInteger; external name '__gmp_errno';

{ Extensions to the GMP library, implemented in this unit }

procedure mpf_exp    (var Dest: mpf_t; protected var Src: mpf_t);
procedure mpf_ln     (var Dest: mpf_t; protected var Src: mpf_t);
procedure mpf_pow    (var Dest: mpf_t; protected var Src1, Src2: mpf_t);
procedure mpf_sin    (var Dest: mpf_t; protected var Src: mpf_t);
procedure mpf_cos    (var Dest: mpf_t; protected var Src: mpf_t);
procedure mpf_arctan (var Dest: mpf_t; protected var Src: mpf_t);
procedure mpf_pi     (var Dest: mpf_t);

implementation

{$L gmp}

{ @@ Should rather be inline and in the interface }

function mpz_sgn (protected var Src: mpz_t): CInteger;
begin
  if Src.mp_size < 0 then
    mpz_sgn := -1
  else if Src.mp_size > 0 then
    mpz_sgn := 1
  else
    mpz_sgn := 0
end;

function mpq_sgn (protected var Src: mpq_t): CInteger;
begin
  if Src.mp_num.mp_size < 0 then
    mpq_sgn := -1
  else if Src.mp_num.mp_size > 0 then
    mpq_sgn := 1
  else
    mpq_sgn := 0
end;

function mpf_sgn (protected var Src: mpf_t) : CInteger;
begin
  if Src.mp_size < 0 then
    mpf_sgn := -1
  else if Src.mp_size > 0 then
    mpf_sgn := 1
  else
    mpf_sgn := 0
end;

{$ifndef HAVE_GMP4}
function GetExp (protected var x: mpf_t) = Exp: mp_exp_t; attribute (inline);
{ @@ This is a kludge, but how to get the exponent (of base 2) in a better way? }
begin
  Dispose (mpf_get_str (nil, Exp, 2, 0, x))
end;
{$else}
function GetExp (protected var x: mpf_t) = Exp: MedInt; attribute (inline);
begin
  Discard (mpf_get_d_2exp (Exp, x))
end;
{$endif}

procedure mpf_exp (var Dest: mpf_t; protected var Src: mpf_t);
{ $$ \exp x = \sum_{n = 0}^{\infty} \frac{x^n}{n!} $$
  The series is used for $x \in [0, 1]$, other values of $x$ are scaled. }
var
  y, s, c0: mpf_t;
  Precision, n: MedCard;
  Exp, i: mp_exp_t;
  Negative: Boolean;
begin
  Precision := mpf_get_prec (Dest);
  mpf_init2 (y, Precision);
  mpf_set (y, Src);
  mpf_set_ui (Dest, 1);
  Negative := mpf_sgn (y) < 0;
  if Negative then mpf_neg (y, y);
  Exp := GetExp (y);
  if Exp > 0 then mpf_div_2exp (y, y, Exp);
  mpf_init2 (c0, Precision);
  mpf_init2 (s, Precision);
  mpf_set_ui (s, 1);
  n := 1;
  repeat
    mpf_mul (s, s, y);
    mpf_div_ui (s, s, n);
    mpf_set (c0, Dest);
    mpf_add (Dest, Dest, s);
    Inc (n)
  until mpf_eq (c0, Dest, Precision) <> 0;
  for i := 1 to Exp do mpf_mul (Dest, Dest, Dest);
  if Negative then mpf_ui_div (Dest, 1, Dest);
  mpf_clear (s);
  mpf_clear (c0);
  mpf_clear (y)
end;

procedure mpf_ln (var Dest: mpf_t; protected var Src: mpf_t);
{ $$ \ln x = \sum_{n = 1}^{\infty} - \frac{(1-x)^n}{n}, \quad x \in ]0, 2] \Rightarrow $$
  $$ \ln 2^i y = -i \ln \frac{1}{2} + \sum_{n = 1}^{\infty} - \frac{(1-y)^n}{n},
     \quad y \in \left[ \frac{1}{2}, 1 \right], i \in \mathbf{Z} $$ }
var
  y, s, p, c0, Half: mpf_t;
  LnHalf: mpf_t; attribute (static);
  LnHalfInited: Boolean = False; attribute (static);
  n, Precision: MedCard;
  Exp: mp_exp_t;
begin
  if mpf_sgn (Src) <= 0 then
    begin
      Discard (Ln (0));  { Generate an error }
      Exit
    end;
  Precision := mpf_get_prec (Dest);
  mpf_init2 (y, Precision);
  mpf_set (y, Src);
  mpf_set_ui (Dest, 0);
  Exp := GetExp (y);
  if Exp <> 0 then
    begin
      if not LnHalfInited or (mpf_get_prec (LnHalf) < Precision) then
        begin
          if LnHalfInited then mpf_clear (LnHalf);
          LnHalfInited := True;
          mpf_init2 (LnHalf, Precision);
          mpf_init2 (Half, Precision);
          mpf_set_d (Half, 0.5);
          mpf_ln (LnHalf, Half);
          mpf_clear (Half)
        end;
      mpf_set (Dest, LnHalf);
      mpf_mul_ui (Dest, Dest, Abs (Exp));
      if Exp > 0 then
        begin
          mpf_neg (Dest, Dest);
          mpf_div_2exp (y, y, Exp)
        end
      else
        mpf_mul_2exp (y, y, - Exp)
    end;
  mpf_ui_sub (y, 1, y);
  mpf_init2 (c0, Precision);
  mpf_init2 (s, Precision);
  mpf_init2 (p, Precision);
  mpf_set_si (p, -1);
  n := 1;
  repeat
    mpf_mul (p, p, y);
    mpf_div_ui (s, p, n);
    mpf_set (c0, Dest);
    mpf_add (Dest, Dest, s);
    Inc (n)
  until mpf_eq (c0, Dest, Precision) <> 0;
  mpf_clear (p);
  mpf_clear (s);
  mpf_clear (c0);
  mpf_clear (y)
end;

procedure mpf_pow (var Dest: mpf_t; protected var Src1, Src2: mpf_t);
var Temp: mpf_t;
begin
  mpf_init2 (Temp, mpf_get_prec (Src1));
  mpf_ln (Temp, Src1);
  mpf_mul (Temp, Temp, Src2);
  mpf_exp (Dest, Temp);
  mpf_clear (Temp)
end;

procedure mpf_sin (var Dest: mpf_t; protected var Src: mpf_t);
{ $$ \sin x = \sum_{n = 0}^{\infty} (-1)^n \frac{x^{2n+1}}{(2n+1)!} $$
  after reduction to range $[0, \pi/2[$ }
var
  Precision, Quadrant, n: MedCard;
  Sign: CInteger;
  a, b, z, xx, c0: mpf_t;
begin
  Precision := mpf_get_prec (Dest);
  mpf_init2 (a, Precision);
  mpf_init2 (b, Precision);
  mpf_init2 (z, Precision);
  mpf_init2 (xx, Precision);
  mpf_init2 (c0, Precision);
  Sign := mpf_sgn (Src);
  mpf_abs (xx, Src);
  mpf_pi (z);
  mpf_div_2exp (z, z, 1);
  mpf_div (a, xx, z);
  mpf_floor (xx, a);
  if mpf_cmp_ui (xx, 4) >= 0 then
    begin
      mpf_div_2exp (b, xx, 2);
      mpf_floor (b, b);
      mpf_mul_2exp (b, b, 2);
      mpf_sub (b, xx, b)
    end
  else
    mpf_set (b, xx);
{$ifdef HAVE_GMP4}
  Quadrant := mpf_get_ui (b);
{$else}
  Quadrant := Round (mpf_get_d (b));
{$endif}
  mpf_sub (b, a, xx);
  mpf_mul (xx, z, b);
  if Quadrant > 1 then
    Sign := -Sign;
  if Odd (Quadrant) then
    mpf_sub (xx, z, xx);
  mpf_mul (z, xx, xx);
  mpf_neg (z, z);
  n := 1;
  mpf_set_ui (b, 1);
  mpf_set_ui (Dest, 1);
  repeat
    Inc (n);
    mpf_div_ui (b, b, n);
    Inc (n);
    mpf_div_ui (b, b, n);
    mpf_mul (b, b, z);
    mpf_set (c0, Dest);
    mpf_add (Dest, Dest, b)
  until mpf_eq (c0, Dest, Precision) <> 0;
  mpf_mul (Dest, Dest, xx);
  if Sign < 0 then
    mpf_neg (Dest, Dest);
  mpf_clear (a);
  mpf_clear (b);
  mpf_clear (z);
  mpf_clear (xx);
  mpf_clear (c0)
end;

procedure mpf_cos (var Dest: mpf_t; protected var Src: mpf_t);
var Temp: mpf_t;
begin
  mpf_init2 (Temp, mpf_get_prec (Dest));
  mpf_pi (Temp);
  mpf_div_2exp (Temp, Temp, 1);
  mpf_sub (Temp, Temp, Src);
  mpf_sin (Dest, Temp);
  mpf_clear (Temp)
end;

procedure mpf_arctan (var Dest: mpf_t; protected var Src: mpf_t);
{ $$\arctan x = \sum_{n=0}^{\infty} (-1)^n \frac{x^{2n+1}}{2n+1}$$
  after double range reduction
  around $\tan(3\pi/8) = \sqrt{2}+1$ with $\arctan x = \pi/2+\arctan(-1/x)$
  around $\tan(\pi/8) = \sqrt{2}-1$  with $\arctan x = \pi/4+\arctan((x-1)/(x+1))$ }
var
  Precision, n: MedCard;
  xx, mx2, a, b: mpf_t;
  SqRtTwo: mpf_t; attribute (static);
  SqRtTwoInited: Boolean = False; attribute (static);
begin
  Precision := mpf_get_prec (Dest);
  mpf_init2 (xx, Precision);
  mpf_init2 (mx2, Precision);
  mpf_init2 (a, Precision);
  mpf_init2 (b, Precision);
  mpf_abs (xx, Src);
  if not SqRtTwoInited or (mpf_get_prec (SqRtTwo) < Precision) then
    begin
      if SqRtTwoInited then mpf_clear (SqRtTwo);
      SqRtTwoInited := True;
      mpf_init2 (SqRtTwo, Precision);
      mpf_sqrt_ui (SqRtTwo, 2)
    end;
  mpf_add_ui (a, SqRtTwo, 1);
  if mpf_cmp (xx, a) > 0 then
    begin
      mpf_pi (Dest);
      mpf_div_2exp (Dest, Dest, 1);
      mpf_ui_div (xx, 1, xx);
      mpf_neg (xx, xx)
    end
  else
    begin
      mpf_sub_ui (b, SqRtTwo, 1);
      if mpf_cmp (xx, b) > 0 then
        begin
          mpf_pi (Dest);
          mpf_div_2exp (Dest, Dest, 2);
          mpf_sub_ui (a, xx, 1);
          mpf_add_ui (b, xx, 1);
          mpf_div (xx, a, b)
        end
      else
        mpf_set_ui (Dest, 0)
    end;
  mpf_mul (mx2, xx, xx);
  mpf_neg (mx2, mx2);
  mpf_add (Dest, Dest, xx);
  n := 1;
  repeat
    mpf_mul (xx, xx, mx2);
    mpf_div_ui (a, xx, 2 * n + 1);
    mpf_set (b, Dest);
    mpf_add (Dest, Dest, a);
    Inc (n)
  until mpf_eq (b, Dest, Precision) <> 0;
  if mpf_sgn (Src) < 0 then
    mpf_neg (Dest, Dest);
  mpf_clear (xx);
  mpf_clear (mx2);
  mpf_clear (a);
  mpf_clear (b)
end;

procedure mpf_pi (var Dest: mpf_t);
{ 4 arctan 1/5 - arctan 1/239 = pi/4 }
var
  b: mpf_t;
  Precision: MedCard;
  Pi: mpf_t; attribute (static);
  PiInited: Boolean = False; attribute (static);
begin
  Precision := mpf_get_prec (Dest);
  if not PiInited or (mpf_get_prec (Pi) < Precision) then
    begin
      if PiInited then mpf_clear (Pi);
      PiInited := True;
      mpf_init2 (Pi, Precision);
      mpf_set_ui (Pi, 1);
      mpf_div_ui (Pi, Pi, 5);
      mpf_arctan (Pi, Pi);
      mpf_mul_ui (Pi, Pi, 4);
      mpf_init2 (b, Precision);
      mpf_set_ui (b, 1);
      mpf_div_ui (b, b, 239);
      mpf_arctan (b, b);
      mpf_sub (Pi, Pi, b);
      mpf_mul_ui (Pi, Pi, 4);
      mpf_clear (b)
    end;
  mpf_set (Dest, Pi)
end;

end.
