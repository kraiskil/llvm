//===-- ARM.td - Describe the ARM Target Machine -----------*- tablegen -*-===//
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
// ARM Subtarget state.
//

def ModeThumb  : SubtargetFeature<"thumb-mode", "InThumbMode", "true",
                                  "Thumb mode">;

//===----------------------------------------------------------------------===//
// ARM Subtarget features.
//

def FeatureVFP2 : SubtargetFeature<"vfp2", "HasVFPv2", "true",
                                   "Enable VFP2 instructions">;
def FeatureVFP3 : SubtargetFeature<"vfp3", "HasVFPv3", "true",
                                   "Enable VFP3 instructions",
                                   [FeatureVFP2]>;
def FeatureNEON : SubtargetFeature<"neon", "HasNEON", "true",
                                   "Enable NEON instructions",
                                   [FeatureVFP3]>;
def FeatureThumb2 : SubtargetFeature<"thumb2", "HasThumb2", "true",
                                     "Enable Thumb2 instructions">;
def FeatureNoARM  : SubtargetFeature<"noarm", "NoARM", "true",
                                     "Does not support ARM mode execution",
                                     [ModeThumb]>;
def FeatureFP16   : SubtargetFeature<"fp16", "HasFP16", "true",
                                     "Enable half-precision floating point">;
def FeatureVFP4   : SubtargetFeature<"vfp4", "HasVFPv4", "true",
                                     "Enable VFP4 instructions",
                                     [FeatureVFP3, FeatureFP16]>;
def FeatureFPARMv8 : SubtargetFeature<"fp-armv8", "HasFPARMv8",
                                   "true", "Enable ARMv8 FP",
                                   [FeatureVFP4]>;
def FeatureD16    : SubtargetFeature<"d16", "HasD16", "true",
                                     "Restrict VFP3 to 16 double registers">;
def FeatureHWDiv  : SubtargetFeature<"hwdiv", "HasHardwareDivide", "true",
                                     "Enable divide instructions">;
def FeatureHWDivARM  : SubtargetFeature<"hwdiv-arm",
                                        "HasHardwareDivideInARM", "true",
                                      "Enable divide instructions in ARM mode">;
def FeatureT2XtPk : SubtargetFeature<"t2xtpk", "HasT2ExtractPack", "true",
                                 "Enable Thumb2 extract and pack instructions">;
def FeatureDB     : SubtargetFeature<"db", "HasDataBarrier", "true",
                                   "Has data barrier (dmb / dsb) instructions">;
def FeatureSlowFPBrcc : SubtargetFeature<"slow-fp-brcc", "SlowFPBrcc", "true",
                                         "FP compare + branch is slow">;
def FeatureVFPOnlySP : SubtargetFeature<"fp-only-sp", "FPOnlySP", "true",
                          "Floating point unit supports single precision only">;
def FeaturePerfMon : SubtargetFeature<"perfmon", "HasPerfMon", "true",
                           "Enable support for Performance Monitor extensions">;
def FeatureTrustZone : SubtargetFeature<"trustzone", "HasTrustZone", "true",
                          "Enable support for TrustZone security extensions">;
def FeatureCrypto : SubtargetFeature<"crypto", "HasCrypto", "true",
                          "Enable support for Cryptography extensions",
                          [FeatureNEON]>;
def FeatureCRC : SubtargetFeature<"crc", "HasCRC", "true",
                          "Enable support for CRC instructions">;

// Cyclone has preferred instructions for zeroing VFP registers, which can
// execute in 0 cycles.
def FeatureZCZeroing : SubtargetFeature<"zcz", "HasZeroCycleZeroing", "true",
                                        "Has zero-cycle zeroing instructions">;

// Some processors have FP multiply-accumulate instructions that don't
// play nicely with other VFP / NEON instructions, and it's generally better
// to just not use them.
def FeatureHasSlowFPVMLx : SubtargetFeature<"slowfpvmlx", "SlowFPVMLx", "true",
                                         "Disable VFP / NEON MAC instructions">;

// Cortex-A8 / A9 Advanced SIMD has multiplier accumulator forwarding.
def FeatureVMLxForwarding : SubtargetFeature<"vmlx-forwarding",
                                       "HasVMLxForwarding", "true",
                                       "Has multiplier accumulator forwarding">;

// Some processors benefit from using NEON instructions for scalar
// single-precision FP operations.
def FeatureNEONForFP : SubtargetFeature<"neonfp", "UseNEONForSinglePrecisionFP",
                                        "true",
                                        "Use NEON for single precision FP">;

// Disable 32-bit to 16-bit narrowing for experimentation.
def FeaturePref32BitThumb : SubtargetFeature<"32bit", "Pref32BitThumb", "true",
                                             "Prefer 32-bit Thumb instrs">;

/// Some instructions update CPSR partially, which can add false dependency for
/// out-of-order implementation, e.g. Cortex-A9, unless each individual bit is
/// mapped to a separate physical register. Avoid partial CPSR update for these
/// processors.
def FeatureAvoidPartialCPSR : SubtargetFeature<"avoid-partial-cpsr",
                                               "AvoidCPSRPartialUpdate", "true",
                                 "Avoid CPSR partial update for OOO execution">;

def FeatureAvoidMOVsShOp : SubtargetFeature<"avoid-movs-shop",
                                            "AvoidMOVsShifterOperand", "true",
                                "Avoid movs instructions with shifter operand">;

// Some processors perform return stack prediction. CodeGen should avoid issue
// "normal" call instructions to callees which do not return.
def FeatureHasRAS : SubtargetFeature<"ras", "HasRAS", "true",
                                     "Has return address stack">;

/// Some M architectures don't have the DSP extension (v7E-M vs. v7M)
def FeatureDSPThumb2 : SubtargetFeature<"t2dsp", "Thumb2DSP", "true",
                                 "Supports v7 DSP instructions in Thumb2">;

// Multiprocessing extension.
def FeatureMP : SubtargetFeature<"mp", "HasMPExtension", "true",
                                 "Supports Multiprocessing extension">;

// Virtualization extension - requires HW divide (ARMv7-AR ARMARM - 4.4.8).
def FeatureVirtualization : SubtargetFeature<"virtualization",
                                 "HasVirtualization", "true",
                                 "Supports Virtualization extension",
                                 [FeatureHWDiv, FeatureHWDivARM]>;

// M-series ISA
def FeatureMClass : SubtargetFeature<"mclass", "ARMProcClass", "MClass",
                                     "Is microcontroller profile ('M' series)">;

// R-series ISA
def FeatureRClass : SubtargetFeature<"rclass", "ARMProcClass", "RClass",
                                     "Is realtime profile ('R' series)">;

// A-series ISA
def FeatureAClass : SubtargetFeature<"aclass", "ARMProcClass", "AClass",
                                     "Is application profile ('A' series)">;

// Special TRAP encoding for NaCl, which looks like a TRAP in Thumb too.
// See ARMInstrInfo.td for details.
def FeatureNaClTrap : SubtargetFeature<"nacl-trap", "UseNaClTrap", "true",
                                       "NaCl trap">;

// ARM ISAs.
def HasV4TOps   : SubtargetFeature<"v4t", "HasV4TOps", "true",
                                   "Support ARM v4T instructions">;
def HasV5TOps   : SubtargetFeature<"v5t", "HasV5TOps", "true",
                                   "Support ARM v5T instructions",
                                   [HasV4TOps]>;
def HasV5TEOps  : SubtargetFeature<"v5te", "HasV5TEOps", "true",
                             "Support ARM v5TE, v5TEj, and v5TExp instructions",
                                   [HasV5TOps]>;
def HasV6Ops    : SubtargetFeature<"v6", "HasV6Ops", "true",
                                   "Support ARM v6 instructions",
                                   [HasV5TEOps]>;
def HasV6MOps   : SubtargetFeature<"v6m", "HasV6MOps", "true",
                                   "Support ARM v6M instructions",
                                   [HasV6Ops]>;
def HasV6KOps   : SubtargetFeature<"v6k", "HasV6KOps", "true",
                                   "Support ARM v6k instructions",
                                   [HasV6Ops]>;
def HasV6T2Ops  : SubtargetFeature<"v6t2", "HasV6T2Ops", "true",
                                   "Support ARM v6t2 instructions",
                                   [HasV6MOps, HasV6KOps, FeatureThumb2]>;
def HasV7Ops    : SubtargetFeature<"v7", "HasV7Ops", "true",
                                   "Support ARM v7 instructions",
                                   [HasV6T2Ops, FeaturePerfMon]>;
def HasV8Ops    : SubtargetFeature<"v8", "HasV8Ops", "true",
                                   "Support ARM v8 instructions",
                                   [HasV7Ops, FeatureVirtualization,
                                    FeatureMP]>;
def FeatureV8_1a : SubtargetFeature<"v8.1a", "HasV8_1a", "true",
                                   "Support ARM v8.1a instructions",
                                   [HasV8Ops, FeatureAClass, FeatureCRC]>;

//===----------------------------------------------------------------------===//
// ARM Processors supported.
//

include "ARMSchedule.td"

// ARM processor families.
def ProcA5      : SubtargetFeature<"a5", "ARMProcFamily", "CortexA5",
                                   "Cortex-A5 ARM processors",
                                   [FeatureSlowFPBrcc, FeatureHasSlowFPVMLx,
                                    FeatureVMLxForwarding, FeatureT2XtPk,
                                    FeatureTrustZone, FeatureMP]>;
def ProcA7      : SubtargetFeature<"a7", "ARMProcFamily", "CortexA7",
                                   "Cortex-A7 ARM processors",
                                   [FeatureSlowFPBrcc, FeatureHasSlowFPVMLx,
                                    FeatureVMLxForwarding, FeatureT2XtPk,
                                    FeatureVFP4, FeatureMP,
                                    FeatureHWDiv, FeatureHWDivARM,
                                    FeatureTrustZone, FeatureVirtualization]>;
def ProcA8      : SubtargetFeature<"a8", "ARMProcFamily", "CortexA8",
                                   "Cortex-A8 ARM processors",
                                   [FeatureSlowFPBrcc, FeatureHasSlowFPVMLx,
                                    FeatureVMLxForwarding, FeatureT2XtPk,
                                    FeatureTrustZone]>;
def ProcA9      : SubtargetFeature<"a9", "ARMProcFamily", "CortexA9",
                                   "Cortex-A9 ARM processors",
                                   [FeatureVMLxForwarding,
                                    FeatureT2XtPk, FeatureFP16,
                                    FeatureAvoidPartialCPSR,
                                    FeatureTrustZone]>;
def ProcSwift   : SubtargetFeature<"swift", "ARMProcFamily", "Swift",
                                   "Swift ARM processors",
                                   [FeatureNEONForFP, FeatureT2XtPk,
                                    FeatureVFP4, FeatureMP, FeatureHWDiv,
                                    FeatureHWDivARM, FeatureAvoidPartialCPSR,
                                    FeatureAvoidMOVsShOp,
                                    FeatureHasSlowFPVMLx, FeatureTrustZone]>;
def ProcA12     : SubtargetFeature<"a12", "ARMProcFamily", "CortexA12",
                                   "Cortex-A12 ARM processors",
                                   [FeatureVMLxForwarding,
                                    FeatureT2XtPk, FeatureVFP4,
                                    FeatureHWDiv, FeatureHWDivARM,
                                    FeatureAvoidPartialCPSR,
                                    FeatureVirtualization,
                                    FeatureTrustZone]>;


// FIXME: It has not been determined if A15 has these features.
def ProcA15      : SubtargetFeature<"a15", "ARMProcFamily", "CortexA15",
                                   "Cortex-A15 ARM processors",
                                   [FeatureT2XtPk, FeatureVFP4,
                                    FeatureMP, FeatureHWDiv, FeatureHWDivARM,
                                    FeatureAvoidPartialCPSR,
                                    FeatureTrustZone, FeatureVirtualization]>;

def ProcA17     : SubtargetFeature<"a17", "ARMProcFamily", "CortexA17",
                                   "Cortex-A17 ARM processors",
                                   [FeatureVMLxForwarding,
                                    FeatureT2XtPk, FeatureVFP4,
                                    FeatureHWDiv, FeatureHWDivARM,
                                    FeatureAvoidPartialCPSR,
                                    FeatureVirtualization,
                                    FeatureTrustZone]>;

def ProcA53     : SubtargetFeature<"a53", "ARMProcFamily", "CortexA53",
                                   "Cortex-A53 ARM processors",
                                   [FeatureHWDiv, FeatureHWDivARM,
                                    FeatureTrustZone, FeatureT2XtPk,
                                    FeatureCrypto, FeatureCRC]>;

def ProcA57     : SubtargetFeature<"a57", "ARMProcFamily", "CortexA57",
                                   "Cortex-A57 ARM processors",
                                   [FeatureHWDiv, FeatureHWDivARM,
                                    FeatureTrustZone, FeatureT2XtPk,
                                    FeatureCrypto, FeatureCRC]>;

def ProcR5      : SubtargetFeature<"r5", "ARMProcFamily", "CortexR5",
                                   "Cortex-R5 ARM processors",
                                   [FeatureSlowFPBrcc,
                                    FeatureHWDiv, FeatureHWDivARM,
                                    FeatureHasSlowFPVMLx,
                                    FeatureAvoidPartialCPSR,
                                    FeatureT2XtPk]>;

// FIXME: krait has currently the same features as A9
// plus VFP4 and hardware division features.
def ProcKrait   : SubtargetFeature<"krait", "ARMProcFamily", "Krait",
                                   "Qualcomm ARM processors",
                                   [FeatureVMLxForwarding,
                                    FeatureT2XtPk, FeatureFP16,
                                    FeatureAvoidPartialCPSR,
                                    FeatureTrustZone,
                                    FeatureVFP4,
                                    FeatureHWDiv,
                                    FeatureHWDivARM]>;


class ProcNoItin<string Name, list<SubtargetFeature> Features>
 : Processor<Name, NoItineraries, Features>;

// V4 Processors.
def : ProcNoItin<"generic",         []>;
def : ProcNoItin<"arm8",            []>;
def : ProcNoItin<"arm810",          []>;
def : ProcNoItin<"strongarm",       []>;
def : ProcNoItin<"strongarm110",    []>;
def : ProcNoItin<"strongarm1100",   []>;
def : ProcNoItin<"strongarm1110",   []>;

// V4T Processors.
def : ProcNoItin<"arm7tdmi",        [HasV4TOps]>;
def : ProcNoItin<"arm7tdmi-s",      [HasV4TOps]>;
def : ProcNoItin<"arm710t",         [HasV4TOps]>;
def : ProcNoItin<"arm720t",         [HasV4TOps]>;
def : ProcNoItin<"arm9",            [HasV4TOps]>;
def : ProcNoItin<"arm9tdmi",        [HasV4TOps]>;
def : ProcNoItin<"arm920",          [HasV4TOps]>;
def : ProcNoItin<"arm920t",         [HasV4TOps]>;
def : ProcNoItin<"arm922t",         [HasV4TOps]>;
def : ProcNoItin<"arm940t",         [HasV4TOps]>;
def : ProcNoItin<"ep9312",          [HasV4TOps]>;

// V5T Processors.
def : ProcNoItin<"arm10tdmi",       [HasV5TOps]>;
def : ProcNoItin<"arm1020t",        [HasV5TOps]>;

// V5TE Processors.
def : ProcNoItin<"arm9e",           [HasV5TEOps]>;
def : ProcNoItin<"arm926ej-s",      [HasV5TEOps]>;
def : ProcNoItin<"arm946e-s",       [HasV5TEOps]>;
def : ProcNoItin<"arm966e-s",       [HasV5TEOps]>;
def : ProcNoItin<"arm968e-s",       [HasV5TEOps]>;
def : ProcNoItin<"arm10e",          [HasV5TEOps]>;
def : ProcNoItin<"arm1020e",        [HasV5TEOps]>;
def : ProcNoItin<"arm1022e",        [HasV5TEOps]>;
def : ProcNoItin<"xscale",          [HasV5TEOps]>;
def : ProcNoItin<"iwmmxt",          [HasV5TEOps]>;

// V6 Processors.
def : Processor<"arm1136j-s",       ARMV6Itineraries, [HasV6Ops]>;
def : Processor<"arm1136jf-s",      ARMV6Itineraries, [HasV6Ops, FeatureVFP2,
                                                       FeatureHasSlowFPVMLx]>;

// V6M Processors.
def : Processor<"cortex-m0",        ARMV6Itineraries, [HasV6MOps, FeatureNoARM,
                                                       FeatureDB, FeatureMClass]>;
def : Processor<"cortex-m0plus",    ARMV6Itineraries, [HasV6MOps, FeatureNoARM,
                                                       FeatureDB, FeatureMClass]>;
def : Processor<"cortex-m1",        ARMV6Itineraries, [HasV6MOps, FeatureNoARM,
                                                       FeatureDB, FeatureMClass]>;
def : Processor<"sc000",            ARMV6Itineraries, [HasV6MOps, FeatureNoARM,
                                                       FeatureDB, FeatureMClass]>;

// V6K Processors.
def : Processor<"arm1176jz-s",      ARMV6Itineraries, [HasV6KOps]>;
def : Processor<"arm1176jzf-s",     ARMV6Itineraries, [HasV6KOps, FeatureVFP2,
                                                       FeatureHasSlowFPVMLx]>;
def : Processor<"mpcorenovfp",      ARMV6Itineraries, [HasV6KOps]>;
def : Processor<"mpcore",           ARMV6Itineraries, [HasV6KOps, FeatureVFP2,
                                                       FeatureHasSlowFPVMLx]>;

// V6T2 Processors.
def : Processor<"arm1156t2-s",      ARMV6Itineraries, [HasV6T2Ops,
                                                       FeatureDSPThumb2]>;
def : Processor<"arm1156t2f-s",     ARMV6Itineraries, [HasV6T2Ops, FeatureVFP2,
                                                       FeatureHasSlowFPVMLx,
                                                       FeatureDSPThumb2]>;

// V7a Processors.
// FIXME: A5 has currently the same Schedule model as A8
def : ProcessorModel<"cortex-a5",   CortexA8Model,
                                    [ProcA5, HasV7Ops, FeatureNEON, FeatureDB,
                                     FeatureVFP4, FeatureDSPThumb2,
                                     FeatureHasRAS, FeatureAClass]>;
def : ProcessorModel<"cortex-a7",   CortexA8Model,
                                    [ProcA7, HasV7Ops, FeatureNEON, FeatureDB,
                                     FeatureDSPThumb2, FeatureHasRAS,
                                     FeatureAClass]>;
def : ProcessorModel<"cortex-a8",   CortexA8Model,
                                    [ProcA8, HasV7Ops, FeatureNEON, FeatureDB,
                                     FeatureDSPThumb2, FeatureHasRAS,
                                     FeatureAClass]>;
def : ProcessorModel<"cortex-a9",   CortexA9Model,
                                    [ProcA9, HasV7Ops, FeatureNEON, FeatureDB,
                                     FeatureDSPThumb2, FeatureHasRAS, FeatureMP,
                                     FeatureAClass]>;

// FIXME: A12 has currently the same Schedule model as A9
def : ProcessorModel<"cortex-a12", CortexA9Model,
                                    [ProcA12, HasV7Ops, FeatureNEON, FeatureDB,
                                     FeatureDSPThumb2, FeatureMP,
                                     FeatureHasRAS, FeatureAClass]>;

// FIXME: A15 has currently the same ProcessorModel as A9.
def : ProcessorModel<"cortex-a15",   CortexA9Model,
                                    [ProcA15, HasV7Ops, FeatureNEON, FeatureDB,
                                     FeatureDSPThumb2, FeatureHasRAS,
                                     FeatureAClass]>;

// FIXME: A17 has currently the same Schedule model as A9
def : ProcessorModel<"cortex-a17",  CortexA9Model,
                                    [ProcA17, HasV7Ops, FeatureNEON, FeatureDB,
                                     FeatureDSPThumb2, FeatureMP,
                                     FeatureHasRAS, FeatureAClass]>;

// FIXME: krait has currently the same Schedule model as A9
def : ProcessorModel<"krait",       CortexA9Model,
                                    [ProcKrait, HasV7Ops,
                                     FeatureNEON, FeatureDB,
                                     FeatureDSPThumb2, FeatureHasRAS,
                                     FeatureAClass]>;

// FIXME: R5 has currently the same ProcessorModel as A8.
def : ProcessorModel<"cortex-r5",   CortexA8Model,
                                    [ProcR5, HasV7Ops, FeatureDB,
                                     FeatureVFP3, FeatureDSPThumb2,
                                     FeatureHasRAS, FeatureVFPOnlySP,
                                     FeatureD16, FeatureRClass]>;

// FIXME: R7 has currently the same ProcessorModel as A8 and is modelled as R5.
def : ProcessorModel<"cortex-r7",   CortexA8Model,
                                    [ProcR5, HasV7Ops, FeatureDB,
                                     FeatureVFP3, FeatureDSPThumb2,
                                     FeatureHasRAS, FeatureVFPOnlySP,
                                     FeatureD16, FeatureMP, FeatureRClass]>;

// V7M Processors.
def : ProcNoItin<"cortex-m3",       [HasV7Ops,
                                     FeatureThumb2, FeatureNoARM, FeatureDB,
                                     FeatureHWDiv, FeatureMClass]>;
def : ProcNoItin<"sc300",           [HasV7Ops,
                                     FeatureThumb2, FeatureNoARM, FeatureDB,
                                     FeatureHWDiv, FeatureMClass]>;

// V7EM Processors.
def : ProcNoItin<"cortex-m4",       [HasV7Ops,
                                     FeatureThumb2, FeatureNoARM, FeatureDB,
                                     FeatureHWDiv, FeatureDSPThumb2,
                                     FeatureT2XtPk, FeatureVFP4,
                                     FeatureVFPOnlySP, FeatureD16,
                                     FeatureMClass]>;
def : ProcNoItin<"cortex-m7",       [HasV7Ops,
                                     FeatureThumb2, FeatureNoARM, FeatureDB,
                                     FeatureHWDiv, FeatureDSPThumb2,
                                     FeatureT2XtPk, FeatureFPARMv8,
                                     FeatureD16, FeatureMClass]>;


// Swift uArch Processors.
def : ProcessorModel<"swift",       SwiftModel,
                                    [ProcSwift, HasV7Ops, FeatureNEON,
                                     FeatureDB, FeatureDSPThumb2,
                                     FeatureHasRAS, FeatureAClass]>;

// V8 Processors
def : ProcNoItin<"cortex-a53",      [ProcA53, HasV8Ops, FeatureAClass,
                                    FeatureDB, FeatureFPARMv8,
                                    FeatureNEON, FeatureDSPThumb2]>;
def : ProcNoItin<"cortex-a57",      [ProcA57, HasV8Ops, FeatureAClass,
                                    FeatureDB, FeatureFPARMv8,
                                    FeatureNEON, FeatureDSPThumb2]>;
// FIXME: Cortex-A72 is currently modelled as an Cortex-A57.
def : ProcNoItin<"cortex-a72",      [ProcA57, HasV8Ops, FeatureAClass,
                                    FeatureDB, FeatureFPARMv8,
                                    FeatureNEON, FeatureDSPThumb2]>;

// Cyclone is very similar to swift
def : ProcessorModel<"cyclone",     SwiftModel,
                                    [ProcSwift, HasV8Ops, HasV7Ops,
                                     FeatureCrypto, FeatureFPARMv8,
                                     FeatureDB,FeatureDSPThumb2,
                                     FeatureHasRAS, FeatureZCZeroing]>;

// V8.1 Processors
def : ProcNoItin<"generic-armv8.1-a", [HasV8Ops, FeatureV8_1a,
                                       FeatureDB, FeatureFPARMv8,
                                       FeatureNEON, FeatureDSPThumb2,
                                       FeatureHWDiv, FeatureHWDivARM,
                                       FeatureTrustZone, FeatureT2XtPk,
                                       FeatureCrypto]>;

//===----------------------------------------------------------------------===//
// Register File Description
//===----------------------------------------------------------------------===//

include "ARMRegisterInfo.td"

include "ARMCallingConv.td"

//===----------------------------------------------------------------------===//
// Instruction Descriptions
//===----------------------------------------------------------------------===//

include "ARMInstrInfo.td"

def ARMInstrInfo : InstrInfo;

//===----------------------------------------------------------------------===//
// Declare the target which we are implementing
//===----------------------------------------------------------------------===//

def ARM : Target {
  // Pull in Instruction Info:
  let InstructionSet = ARMInstrInfo;
}
