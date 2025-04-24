//===-- RISCVInstrInfoXSecure.td - XSecure extension for ROL/ROR/RORI -----*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file describes the "Xsecure" vendor extension, which adds three
// custom rotate instructions: 'rol', 'ror', and 'rori'.
//
// ROL, ROR = R-type (opcode 0110011, funct7=0110000)
// RORI     = I-type (opcode 0010011, funct7=0110000)
//
// Usage notes:
//   - To enable assembler/disassembler support, pass -mattr=+Xsecure or
//     use a CPU definition that includes FeatureVendorXSecure.
//
//===----------------------------------------------------------------------===//

///////////////////////////////////////////////////////////
// 1) R-Format and I-Format classes for these instructions
///////////////////////////////////////////////////////////

class XSECURE_RType<dag outs, dag ins,
                    string opcodeStr, string asmStr,
                    bits<7> funct7,
                    bits<3> funct3,
                    bits<7> opcode>
    : RVInst<outs, ins, opcodeStr, asmStr, [], InstFormatR>
{
  // Declare these so TableGen knows how to wire them up:
  bits<5> rd;
  bits<5> rs1;
  bits<5> rs2;

  let Inst{31-25} = funct7;
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = funct3;
  let Inst{11-7}  = rd;
  let Inst{6-0}   = opcode;
}

class XSECURE_IType<dag outs, dag ins,
                    string opcodeStr, string asmStr,
                    bits<7> funct7,
                    bits<3> funct3,
                    bits<7> opcode>
    : RVInst<outs, ins, opcodeStr, asmStr, [], InstFormatI>
{
  // Declare fields for rd, rs1, and the 5-bit shift amount:
  bits<5> rd;
  bits<5> rs1;
  bits<5> ShamtField;

  let Inst{31-25} = funct7;
  let Inst{24-20} = ShamtField;
  let Inst{19-15} = rs1;
  let Inst{14-12} = funct3;
  let Inst{11-7}  = rd;
  let Inst{6-0}   = opcode;
}

///////////////////////////////////////////////////////////
// 2) The instructions themselves (ROL, ROR, RORI)
///////////////////////////////////////////////////////////

let Predicates       = [HasVendorXSecure],
    hasSideEffects   = 0,
    mayLoad         = 0,
    mayStore        = 0,
    DecoderNamespace= "Xsecure"
in {

  // R-type
  //  - ROL => opcode=0110011, funct7=0110000, funct3=001
  //  - ROR => opcode=0110011, funct7=0110000, funct3=101

  def XSECURE_ROL
    : XSECURE_RType<
        (outs GPR:$rd),
        (ins GPR:$rs1, GPR:$rs2),
        "openstealth.rol",
        "$rd, $rs1, $rs2",
        0b0110000, //funct7
        0b001,     //funct3
        0b0110011  //opcode
      >,
      Sched<[]> {
      let DecoderMethod = "decodeRVR";
      }

  def XSECURE_ROR
    : XSECURE_RType<
        (outs GPR:$rd),
        (ins GPR:$rs1, GPR:$rs2),
        "openstealth.ror",
        "$rd, $rs1, $rs2",
        0b0110000, //funct7
        0b101,     //funct3
        0b0110011  //opcode
      >,
      Sched<[]> {
      let DecoderMethod = "decodeRVR";
      }

  // I-type
  //  - RORI => opcode=0010011, funct7=0110000, funct3=101
  //  - We reuse 'uimm5:$shamt' for the 5-bit immediate.
  def XSECURE_RORI
    : XSECURE_IType<
        (outs GPR:$rd),
        (ins GPR:$rs1, uimm5:$ShamtField),  // tie the operand to ShamtField
        "openstealth.rori",
        "$rd, $rs1, $ShamtField",
        0b0110000, //funct7
        0b101,     //funct3
        0b0010011  //opcode
      >
  {
    let DecoderMethod = "decodeRVIShiftImm";
  }
}

//===----------------------------------------------------------------------===//
// 3) Assembler Aliases
//
// Provide textual mnemonics so the assembler can parse 'rol', 'ror', 'rori'.
// This is crucial! Without these, clang won't encode them properly.
//===----------------------------------------------------------------------===//

def : InstAlias<"openstealth.rol $rd, $rs1, $rs2",
                (XSECURE_ROL GPR:$rd, GPR:$rs1, GPR:$rs2)>
{
  let Predicates = [HasVendorXSecure];
}

def : InstAlias<"openstealth.ror $rd, $rs1, $rs2",
                (XSECURE_ROR GPR:$rd, GPR:$rs1, GPR:$rs2)>
{
  let Predicates = [HasVendorXSecure];
}

def : InstAlias<"openstealth.rori $rd, $rs1, $uimm5",
                (XSECURE_RORI GPR:$rd, GPR:$rs1, uimm5:$uimm5)>
{
  let Predicates = [HasVendorXSecure];
}
