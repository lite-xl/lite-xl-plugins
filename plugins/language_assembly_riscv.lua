-- mod-version:3
-- Support for RISC-V assembly
-- Note: kinda conflicts with x86 asm, must uninstall it or use force-syntax plugin
-- https://github.com/cheyao
local syntax = require "core.syntax"

syntax.add {
  name = "RISC-V Assembly",
  files = { "%.asm$", "%.[sS]$" },
  comment = "#",
  patterns = {
    { pattern = "#.*\n", type = "comment" },
    { pattern = { '"', '"', '\\' }, type = "string" },
    { pattern = { "'", "'", '\\' }, type = "string" },
    { pattern = "0[bB][0-1]+%W", type = "number" },
    { pattern = "0[xX]%x+", type = "number" },
    { pattern = "%%+[%a_][%w_]*", type = "function" },
    { pattern = "[%a%._][%w%._]*:%W", type = "function" },
    { pattern = "[^%p%a]%-?%d[%d%.]*", type = "number" },
    { pattern = "[%+%-=/%*%^%%<>!~|&%$]", type = "operator" },
    { pattern = "[%a_][%w_]*", type = "symbol" },
    { pattern = "%.%a+", type = "normal" }
  },
  symbols = {
    -- Integer Registers
    ["x0"] = "literal",
    ["x1"] = "literal",
    ["x2"] = "literal",
    ["x3"] = "literal",
    ["x4"] = "literal",
    ["x5"] = "literal",
    ["x6"] = "literal",
    ["x7"] = "literal",
    ["x8"] = "literal",
    ["x9"] = "literal",
    ["x10"] = "literal",
    ["x11"] = "literal",
    ["x12"] = "literal",
    ["x13"] = "literal",
    ["x14"] = "literal",
    ["x15"] = "literal",
    ["x16"] = "literal",
    ["x17"] = "literal",
    ["x18"] = "literal",
    ["x19"] = "literal",
    ["x20"] = "literal",
    ["x21"] = "literal",
    ["x22"] = "literal",
    ["x23"] = "literal",
    ["x24"] = "literal",
    ["x25"] = "literal",
    ["x26"] = "literal",
    ["x27"] = "literal",
    ["x28"] = "literal",
    ["x29"] = "literal",
    ["x30"] = "literal",
    ["x31"] = "literal",
    ["zero"] = "literal",
    ["ra"] = "literal",
    ["sp"] = "literal",
    ["gp"] = "literal",
    ["tp"] = "literal",
    ["t0"] = "literal",
    ["t1"] = "literal",
    ["t2"] = "literal",
    ["fp"] = "literal",
    ["s0"] = "literal",
    ["s1"] = "literal",
    ["a0"] = "literal",
    ["a1"] = "literal",
    ["a2"] = "literal",
    ["a3"] = "literal",
    ["a4"] = "literal",
    ["a5"] = "literal",
    ["a6"] = "literal",
    ["a7"] = "literal",
    ["s2"] = "literal",
    ["s3"] = "literal",
    ["s4"] = "literal",
    ["s5"] = "literal",
    ["s6"] = "literal",
    ["s7"] = "literal",
    ["s8"] = "literal",
    ["s9"] = "literal",
    ["s10"] = "literal",
    ["s11"] = "literal",
    ["t3"] = "literal",
    ["t4"] = "literal",
    ["t5"] = "literal",
    ["t6"] = "literal",
    ["pc"] = "literal",
    -- Floating-point Registers
    ["f0"] = "literal",
    ["f1"] = "literal",
    ["f2"] = "literal",
    ["f3"] = "literal",
    ["f4"] = "literal",
    ["f5"] = "literal",
    ["f6"] = "literal",
    ["f7"] = "literal",
    ["f8"] = "literal",
    ["f9"] = "literal",
    ["f10"] = "literal",
    ["f11"] = "literal",
    ["f12"] = "literal",
    ["f13"] = "literal",
    ["f14"] = "literal",
    ["f15"] = "literal",
    ["f16"] = "literal",
    ["f17"] = "literal",
    ["f18"] = "literal",
    ["f19"] = "literal",
    ["f20"] = "literal",
    ["f21"] = "literal",
    ["f22"] = "literal",
    ["f23"] = "literal",
    ["f24"] = "literal",
    ["f25"] = "literal",
    ["f26"] = "literal",
    ["f27"] = "literal",
    ["f28"] = "literal",
    ["f29"] = "literal",
    ["f30"] = "literal",
    ["f31"] = "literal",
    
    ["ft0"] = "literal",
    ["ft1"] = "literal",
    ["ft2"] = "literal",
    ["ft3"] = "literal",
    ["ft4"] = "literal",
    ["ft5"] = "literal",
    ["ft6"] = "literal",
    ["ft7"] = "literal",
    
    ["fs0"] = "literal",
    ["fs1"] = "literal",
    
    ["fa0"] = "literal",
    ["fa1"] = "literal",
    ["fa2"] = "literal",
    ["fa3"] = "literal",
    ["fa4"] = "literal",
    ["fa5"] = "literal",
    ["fa6"] = "literal",
    ["fa7"] = "literal",
    
    ["fa2"] = "literal",
    ["fa3"] = "literal",
    ["fa4"] = "literal",
    ["fa5"] = "literal",
    ["fa6"] = "literal",
    ["fa7"] = "literal",
    ["fa8"] = "literal",
    ["fa9"] = "literal",
    ["fa10"] = "literal",
    ["fa11"] = "literal",
    
    ["ft8"] = "literal",
    ["ft9"] = "literal",
    ["ft10"] = "literal",
    ["ft11"] = "literal",
    
    -- Vector Registers
    ["v0"] = "literal",
    ["v1"] = "literal",
    ["v2"] = "literal",
    ["v3"] = "literal",
    ["v4"] = "literal",
    ["v5"] = "literal",
    ["v6"] = "literal",
    ["v7"] = "literal",
    ["v8"] = "literal",
    ["v9"] = "literal",
    ["v10"] = "literal",
    ["v11"] = "literal",
    ["v12"] = "literal",
    ["v13"] = "literal",
    ["v14"] = "literal",
    ["v15"] = "literal",
    ["v16"] = "literal",
    ["v17"] = "literal",
    ["v18"] = "literal",
    ["v19"] = "literal",
    ["v20"] = "literal",
    ["v21"] = "literal",
    ["v22"] = "literal",
    ["v23"] = "literal",
    ["v24"] = "literal",
    ["v25"] = "literal",
    ["v26"] = "literal",
    ["v27"] = "literal",
    ["v28"] = "literal",
    ["v29"] = "literal",
    ["v30"] = "literal",
    ["v31"] = "literal",
    
    ["vl"] = "literal",
    ["vtype"] = "literal",
    ["vzrm"] = "literal",
    ["vxsat"] = "literal",

    -- RV32I instructions
    ["lui"] = "keyword",
    ["auipc"] = "keyword",
    ["jal"] = "keyword",
    ["jalr"] = "keyword",
    ["beq"] = "keyword",
    ["bne"] = "keyword",
    ["blt"] = "keyword",
    ["bge"] = "keyword",
    ["bltu"] = "keyword",
    ["bgeu"] = "keyword",
    ["lb"] = "keyword",
    ["lh"] = "keyword",
    ["lw"] = "keyword",
    ["lbu"] = "keyword",
    ["lhu"] = "keyword",
    ["sb"] = "keyword",
    ["sh"] = "keyword",
    ["sw"] = "keyword",
    ["addi"] = "keyword",
    ["slti"] = "keyword",
    ["sltiu"] = "keyword",
    ["xori"] = "keyword",
    ["ori"] = "keyword",
    ["andi"] = "keyword",
    ["slli"] = "keyword",
    ["srli"] = "keyword",
    ["srai"] = "keyword",
    ["add"] = "keyword",
    ["sub"] = "keyword",
    ["sll"] = "keyword",
    ["slt"] = "keyword",
    ["sltu"] = "keyword",
    ["xor"] = "keyword",
    ["srl"] = "keyword",
    ["sra"] = "keyword",
    ["or"] = "keyword",
    ["and"] = "keyword",
    ["fence"] = "keyword",
    ["fence.tso"] = "keyword",
    ["pause"] = "keyword",
    ["ecall"] = "keyword",
    ["ebreak"] = "keyword",

    -- RV64I instructions
    ["lwu"] = "keyword",
    ["ld"] = "keyword",
    ["sd"] = "keyword",
    ["slli"] = "keyword",
    ["srli"] = "keyword",
    ["srai"] = "keyword",
    ["addiw"] = "keyword",
    ["slliw"] = "keyword",
    ["srliw"] = "keyword",
    ["sraiw"] = "keyword",
    ["addw"] = "keyword",
    ["subw"] = "keyword",
    ["sllw"] = "keyword",
    ["srlw"] = "keyword",
    ["sraw"] = "keyword",
    
    -- Zifencei instructions
    ["fence.i"] = "keyword",
    
    -- Zicsr instructions
    ["csrrw"] = "keyword",
    ["csrrs"] = "keyword",
    ["csrrc"] = "keyword",
    ["csrrwi"] = "keyword",
    ["csrrsi"] = "keyword",
    ["csrrci"] = "keyword",
    
    -- RV32M instructions
    ["mul"] = "keyword",
    ["mulh"] = "keyword",
    ["mulhsu"] = "keyword",
    ["mulhu"] = "keyword",
    ["div"] = "keyword",
    ["divu"] = "keyword",
    ["rem"] = "keyword",
    ["remu"] = "keyword",
    
    -- RV64M instructions
    ["mulw"] = "keyword",
    ["divw"] = "keyword",
    ["divuw"] = "keyword",
    ["remw"] = "keyword",
    ["remuw"] = "keyword",
    
    -- RV32A instructions
    ["lr.w"] = "keyword",
    ["sc.w"] = "keyword",
    ["amoswap.w"] = "keyword",
    ["amoadd.w"] = "keyword",
    ["amoxor.w"] = "keyword",
    ["amoand.w"] = "keyword",
    ["amoor.w"] = "keyword",
    ["amomin.w"] = "keyword",
    ["amomax.w"] = "keyword",
    ["amominu.w"] = "keyword",
    ["amomaxu.w"] = "keyword",
    
    -- RV64A instructions
    ["lr.d"] = "keyword",
    ["sc.d"] = "keyword",
    ["amoswap.d"] = "keyword",
    ["amoadd.d"] = "keyword",
    ["amoxor.d"] = "keyword",
    ["amoand.d"] = "keyword",
    ["amoor.d"] = "keyword",
    ["amomin.d"] = "keyword",
    ["amomax.d"] = "keyword",
    ["amominu.d"] = "keyword",
    ["amomaxu.d"] = "keyword",
    
    -- RV32F instructions
    ["flw"] = "keyword",
    ["fsw"] = "keyword",
    ["fmadd.s"] = "keyword",
    ["fmsub.s"] = "keyword",
    ["fnmsub.s"] = "keyword",
    ["fnmadd.s"] = "keyword",
    ["fadd.s"] = "keyword",
    ["fsub.s"] = "keyword",
    ["fmul.s"] = "keyword",
    ["fdiv.s"] = "keyword",
    ["fsqrt.s"] = "keyword",
    ["fsgnj.s"] = "keyword",
    ["fsgnjn.s"] = "keyword",
    ["fsgnjx.s"] = "keyword",
    ["fmin.s"] = "keyword",
    ["fmax.s"] = "keyword",
    ["fcvt.w.s"] = "keyword",
    ["fcvt.wu.s"] = "keyword",
    ["fmv.x.w"] = "keyword",
    ["feq.s"] = "keyword",
    ["flt.s"] = "keyword",
    ["fle.s"] = "keyword",
    ["fclass.s"] = "keyword",
    ["fcvt.s.w"] = "keyword",
    ["fcvt.s.wu"] = "keyword",
    ["fmv.w.x"] = "keyword",
    
    -- RV64F instructions
    ["fcvt.l.s"] = "keyword",
    ["fcvt.lu.s"] = "keyword",
    ["fcvt.s.l"] = "keyword",
    ["fcvt.s.lu"] = "keyword",
    
    -- RV32D instructions
    ["fld"] = "keyword",
    ["fsd"] = "keyword",
    ["fmadd.d"] = "keyword",
    ["fmsub.d"] = "keyword",
    ["fnmsub.d"] = "keyword",
    ["fnmadd.d"] = "keyword",
    ["fadd.d"] = "keyword",
    ["fsub.d"] = "keyword",
    ["fmul.d"] = "keyword",
    ["fdiv.d"] = "keyword",
    ["fsqrt.d"] = "keyword",
    ["fsgnj.d"] = "keyword",
    ["fsgnjn.d"] = "keyword",
    ["fsgnjx.d"] = "keyword",
    ["fmin.d"] = "keyword",
    ["fmax.d"] = "keyword",
    ["fcvt.s.d"] = "keyword",
    ["fcvt.d.s"] = "keyword",
    ["feq.d"] = "keyword",
    ["flt.d"] = "keyword",
    ["fle.d"] = "keyword",
    ["fclass.d"] = "keyword",
    ["fcvt.w.d"] = "keyword",
    ["fcvt.wu.d"] = "keyword",
    ["fcvt.d.w"] = "keyword",
    ["fcvt.d.wu"] = "keyword",
    
    -- RV64D instructions
    ["fcvt.l.d"] = "keyword",
    ["fcvt.lu.d"] = "keyword",
    ["fmv.x.d"] = "keyword",
    ["fcvt.d.l"] = "keyword",
    ["fcvt.d.lu"] = "keyword",
    ["fmv.d.x"] = "keyword",
    
    -- RV32Q instructions
    ["flq"] = "keyword",
    ["fsq"] = "keyword",
    ["fmadd.q"] = "keyword",
    ["fmsub.q"] = "keyword",
    ["fnmsub.q"] = "keyword",
    ["fnmadd.q"] = "keyword",
    ["fadd.q"] = "keyword",
    ["fsub.q"] = "keyword",
    ["fmul.q"] = "keyword",
    ["fdiv.q"] = "keyword",
    ["fsqrt.q"] = "keyword",
    ["fsgnj.q"] = "keyword",
    ["fsgnjn.q"] = "keyword",
    ["fsgnjx.q"] = "keyword",
    ["fmin.q"] = "keyword",
    ["fmax.q"] = "keyword",
    ["fcvt.s.q"] = "keyword",
    ["fcvt.q.s"] = "keyword",
    ["fcvt.d.q"] = "keyword",
    ["fcvt.q.d"] = "keyword",
    ["feq.q"] = "keyword",
    ["flt.q"] = "keyword",
    ["fle.q"] = "keyword",
    ["fclass.q"] = "keyword",
    ["fcvt.w.q"] = "keyword",
    ["fcvt.wu.q"] = "keyword",
    ["fcvt.q.w"] = "keyword",
    ["fcvt.q.wu"] = "keyword",
    
    -- RV64Q instructions
    ["fcvt.l.q"] = "keyword",
    ["fcvt.lu.q"] = "keyword",
    ["fcvt.q.l"] = "keyword",
    ["fcvt.q.lu"] = "keyword",
    
    -- RV32Zfh instructions
    ["flh"] = "keyword",
    ["fsh"] = "keyword",
    ["fmadd.h"] = "keyword",
    ["fmsub.h"] = "keyword",
    ["fnmsub.h"] = "keyword",
    ["fnmadd.h"] = "keyword",
    ["fadd.h"] = "keyword",
    ["fsub.h"] = "keyword",
    ["fmul.h"] = "keyword",
    ["fdiv.h"] = "keyword",
    ["fsqrt.h"] = "keyword",
    ["fsgnj.h"] = "keyword",
    ["fsgnjn.h"] = "keyword",
    ["fsgnjx.h"] = "keyword",
    ["fmin.h"] = "keyword",
    ["fmax.h"] = "keyword",
    ["fcvt.s.h"] = "keyword",
    ["fcvt.h.s"] = "keyword",
    ["fcvt.d.h"] = "keyword",
    ["fcvt.h.d"] = "keyword",
    ["fcvt.q.h"] = "keyword",
    ["fcvt.h.q"] = "keyword",
    ["feq.h"] = "keyword",
    ["flt.h"] = "keyword",
    ["fle.h"] = "keyword",
    ["fclass.h"] = "keyword",
    ["fcvt.w.h"] = "keyword",
    ["fcvt.wu.h"] = "keyword",
    ["fmv.x.h"] = "keyword",
    ["fcvt.h.w"] = "keyword",
    ["fcvt.h.wu"] = "keyword",
    ["fmv.h.x"] = "keyword",

    -- RV64Zfh instructions
    ["fcvt.l.h"] = "keyword",
    ["fcvt.lu.h"] = "keyword",
    ["fcvt.h.l"] = "keyword",
    ["fcvt.h.lu"] = "keyword",

    -- Pesudo-instructions
    ["nop"] = "keyword",
    ["li"] = "keyword",
    ["mv"] = "keyword",
    ["not"] = "keyword",
    ["neg"] = "keyword",
    ["negw"] = "keyword",
    ["sext.w"] = "keyword",
    ["seqz"] = "keyword",
    ["snez"] = "keyword",
    ["sltz"] = "keyword",
    ["sgtz"] = "keyword",
    ["fmv.s"] = "keyword",
    ["fabs.s"] = "keyword",
    ["fneg.s"] = "keyword",
    ["fmv.d"] = "keyword",
    ["fabs.d"] = "keyword",
    ["fneg.d"] = "keyword",
    ["beqz"] = "keyword",
    ["bnez"] = "keyword",
    ["blez"] = "keyword",
    ["bgez"] = "keyword",
    ["bltz"] = "keyword",
    ["bgtz"] = "keyword",
    ["bgt"] = "keyword",
    ["ble"] = "keyword",
    ["bgtu"] = "keyword",
    ["bleu"] = "keyword",
    ["j"] = "keyword",
    ["jr"] = "keyword",
    ["ret"] = "keyword",
    ["call"] = "keyword",
    ["tail"] = "keyword",
    
    -- Other
    [".2byte"] = "keyword2",
    [".4byte"] = "keyword2",
    [".8byte"] = "keyword2",
    [".half"] = "keyword2",
    [".word"] = "keyword2",
    [".dword"] = "keyword2",
    [".byte"] = "keyword2",
    [".dtpreldword"] = "keyword2",
    [".dtprelword"] = "keyword2",
    [".sleb128"] = "keyword2",
    [".uleb128"] = "keyword2",
    [".asciz"] = "keyword2",
    [".string"] = "keyword2",
    [".incbin"] = "keyword2",
    [".zero"] = "keyword2",
    
    [".align"] = "keyword2",
    [".balign"] = "keyword2",
    [".p2align"] = "keyword2",
    
    [".globl"] = "keyword2",
    [".local"] = "keyword2",
    [".equ"] = "keyword2",
    
    [".text"] = "keyword2",
    [".data"] = "keyword2",
    [".rodata"] = "keyword2",
    [".bss"] = "keyword2",
    [".comm"] = "keyword2",
    [".common"] = "keyword2",
    [".section"] = "keyword2",
    
    [".option"] = "keyword2",
    [".macro"] = "keyword2",
    [".endm"] = "keyword2",
    [".file"] = "keyword2",
    [".ident"] = "keyword2",
    [".size"] = "keyword2",
    [".type"] = "keyword2",
  },
}
