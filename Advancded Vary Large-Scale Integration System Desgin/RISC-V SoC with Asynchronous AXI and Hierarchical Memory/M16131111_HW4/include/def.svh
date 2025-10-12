//================================================
// Auther:      Chen Yun-Ru (May)
// Filename:    def.svh
// Description: Hart defination
// Version:     0.1
//================================================
// `ifndef DEF_SVH
// `define DEF_SVH

// CPU
`define DATA_BITS 32



// Cache
`define CACHE_BLOCK_BITS 2
`define CACHE_INDEX_BITS 5
`define CACHE_TAG_BITS 23
`define CACHE_DATA_BITS 128
`define CACHE_LINES 2**(`CACHE_INDEX_BITS)
`define CACHE_WRITE_BITS 16
`define CACHE_TYPE_BITS 3
`define CACHE_BYTE `CACHE_TYPE_BITS'b000
`define CACHE_HWORD `CACHE_TYPE_BITS'b001
`define CACHE_WORD `CACHE_TYPE_BITS'b010
`define CACHE_BYTE_U `CACHE_TYPE_BITS'b100
`define CACHE_HWORD_U `CACHE_TYPE_BITS'b101

//Read Write data length
`define WRITE_LEN_BITS 2
`define BYTE `WRITE_LEN_BITS'b00
`define HWORD `WRITE_LEN_BITS'b01
`define WORD `WRITE_LEN_BITS'b10


// inst format
`define R_type 3'd0
`define I_type 3'd1
`define S_type 3'd2
`define B_type 3'd3
`define U_type 3'd4
`define J_type 3'd5
`define F_L_type 3'd6
`define F_S_type 3'd7

// ALU control
`define ALU_ADD 4'b0000
`define ALU_SUB 4'b1000
`define ALU_SLL 4'b0001
`define ALU_SLT 4'b0010
`define ALU_SLTU 4'b0011
`define ALU_XOR 4'b0100
`define ALU_SRL 4'b0101
`define ALU_SRA 4'b1101
`define ALU_OR 4'b0110
`define ALU_AND 4'b0111

`define ARITHMETIC 7'b0110_011
`define ARITHMETIC_IMM 7'b0010_011
`define LOAD 7'b0000_011
`define STORE 7'b0100_011
`define BRANCH 7'b1100_011
`define AUIPC 7'b0010_111
`define LUI 7'b0110_111
`define JAL 7'b1101_111
`define JALR 7'b1100_111
`define FP_LOAD 7'b000_0111
`define FP_STORE 7'b010_0111
`define FP_ARITHMETIC 7'b1010_011
`define CSR 7'b1110_011


`define ALUOUT    3'd0
`define LOAD_DATA   3'd1
`define PC_PLUS_4 3'd2
`define CSROUT    3'd3
`define MULOUT 3'd4
`define FPOUT 3'd5
`define FP_LOAD_DATA 3'd6
// `endif
