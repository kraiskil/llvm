//=- AArch64.td - Describe the AArch64 Target Machine --------*- tablegen -*-=//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Target-independent interfaces which we are implementing
//===----------------------------------------------------------------------===//

include "llvm/Target/Target.td"

//===----------------------------------------------------------------------===//
// AArch64 Subtarget features.
//

def FeatureFPARMv8 : SubtargetFeature<"fp-armv8", "HasFPARMv8", "true",
                                       "Enable ARMv8 FP">;

def FeatureNEON : SubtargetFeature<"neon", "HasNEON", "true",
  "Enable Advanced SIMD instructions", [FeatureFPARMv8]>;

def FeatureCrypto : SubtargetFeature<"crypto", "HasCrypto", "true",
  "Enable cryptographic instructions">;

def FeatureCRC : SubtargetFeature<"crc", "HasCRC", "true",
  "Enable ARMv8 CRC-32 checksum instructions">;

def FeatureV8_1a : SubtargetFeature<"v8.1a", "HasV8_1a", "true",
  "Enable ARMv8.1a extensions", [FeatureCRC]>;

/// Cyclone has register move instructions which are "free".
def FeatureZCRegMove : SubtargetFeature<"zcm", "HasZeroCycleRegMove", "true",
                                        "Has zero-cycle register moves">;

/// Cyclone has instructions which zero registers for "free".
def FeatureZCZeroing : SubtargetFeature<"zcz", "HasZeroCycleZeroing", "true",
                                        "Has zero-cycle zeroing instructions">;

//===----------------------------------------------------------------------===//
// Register File Description
//===----------------------------------------------------------------------===//

include "AArch64RegisterInfo.td"
include "AArch64CallingConvention.td"

//===----------------------------------------------------------------------===//
// Instruction Descriptions
//===----------------------------------------------------------------------===//

include "AArch64Schedule.td"
include "AArch64InstrInfo.td"

def AArch64InstrInfo : InstrInfo;

//===----------------------------------------------------------------------===//
// AArch64 Processors supported.
//
include "AArch64SchedA53.td"
include "AArch64SchedA57.td"
include "AArch64SchedCyclone.td"

def ProcA53     : SubtargetFeature<"a53", "ARMProcFamily", "CortexA53",
                                   "Cortex-A53 ARM processors",
                                   [FeatureFPARMv8,
                                   FeatureNEON,
                                   FeatureCrypto,
                                   FeatureCRC]>;

def ProcA57     : SubtargetFeature<"a57", "ARMProcFamily", "CortexA57",
                                   "Cortex-A57 ARM processors",
                                   [FeatureFPARMv8,
                                   FeatureNEON,
                                   FeatureCrypto,
                                   FeatureCRC]>;

def ProcCyclone : SubtargetFeature<"cyclone", "ARMProcFamily", "Cyclone",
                                   "Cyclone",
                                   [FeatureFPARMv8,
                                   FeatureNEON,
                                   FeatureCrypto,
                                   FeatureCRC,
                                   FeatureZCRegMove, FeatureZCZeroing]>;

def : ProcessorModel<"generic", NoSchedModel, [FeatureFPARMv8,
                                              FeatureNEON,
                                              FeatureCRC]>;

def : ProcessorModel<"generic-armv8.1-a", NoSchedModel, [FeatureV8_1a,
                                                         FeatureNEON,
                                                         FeatureCrypto]>;

def : ProcessorModel<"cortex-a53", CortexA53Model, [ProcA53]>;
def : ProcessorModel<"cortex-a57", CortexA57Model, [ProcA57]>;
// FIXME: Cortex-A72 is currently modelled as an Cortex-A57.
def : ProcessorModel<"cortex-a72", CortexA57Model, [ProcA57]>;
def : ProcessorModel<"cyclone", CycloneModel, [ProcCyclone]>;

//===----------------------------------------------------------------------===//
// Assembly parser
//===----------------------------------------------------------------------===//

def GenericAsmParserVariant : AsmParserVariant {
  int Variant = 0;
  string Name = "generic";
}

def AppleAsmParserVariant : AsmParserVariant {
  int Variant = 1;
  string Name = "apple-neon";
}

//===----------------------------------------------------------------------===//
// Assembly printer
//===----------------------------------------------------------------------===//
// AArch64 Uses the MC printer for asm output, so make sure the TableGen
// AsmWriter bits get associated with the correct class.
def GenericAsmWriter : AsmWriter {
  string AsmWriterClassName  = "InstPrinter";
  int Variant = 0;
  bit isMCAsmWriter = 1;
}

def AppleAsmWriter : AsmWriter {
  let AsmWriterClassName = "AppleInstPrinter";
  int Variant = 1;
  int isMCAsmWriter = 1;
}

//===----------------------------------------------------------------------===//
// Target Declaration
//===----------------------------------------------------------------------===//

def AArch64 : Target {
  let InstructionSet = AArch64InstrInfo;
  let AssemblyParserVariants = [GenericAsmParserVariant, AppleAsmParserVariant];
  let AssemblyWriters = [GenericAsmWriter, AppleAsmWriter];
}
