
`include "./src/fa.v"

module top(
            input [3:0] A,
            input [3:0] B,
            input Cin,
            output [3:0] S,
            output Cout
);

 // Internal wires for carry and sum outputs of each FA
  wire [3:0] G, P, C; // Generate, Propagate, and Carry signals
  wire C1, C2, C3;     // Intermediate carry signals between FAs

  // Instantiate 4 Full Adders (FA) for 4 bits
  fa fa0 (.a(A[0]), .b(B[0]), .ci(Cin), .sum(S[0]), .cout(C[0]));
  fa fa1 (.a(A[1]), .b(B[1]), .ci(C[0]), .sum(S[1]), .cout(C[1]));
  fa fa2 (.a(A[2]), .b(B[2]), .ci(C[1]), .sum(S[2]), .cout(C[2]));
  fa fa3 (.a(A[3]), .b(B[3]), .ci(C[2]), .sum(S[3]), .cout(Cout));

 // Generate signals (G = A & B)
  and (G0, A[0], B[0]);  // G0 = A[0] AND B[0]
  and (G1, A[1], B[1]);  // G1 = A[1] AND B[1]
  and (G2, A[2], B[2]);  // G2 = A[2] AND B[2]
  and (G3, A[3], B[3]);  // G3 = A[3] AND B[3]

  // Propagate signals (P = A XOR B)
  xor (P0, A[0], B[0]);  // P0 = A[0] XOR B[0]
  xor (P1, A[1], B[1]);  // P1 = A[1] XOR B[1]
  xor (P2, A[2], B[2]);  // P2 = A[2] XOR B[2]
  xor (P3, A[3], B[3]);  // P3 = A[3] XOR B[3]

  // Carry logic (Ci = Gi + (Pi * Ci-1))
  // C0 = G0 + (P0 * Cin)
  wire P0_and_Cin;
  and (P0_and_Cin, P0, Cin);
  or (C0, G0, P0_and_Cin);  // C0 = G0 OR (P0 AND Cin)

  // C1 = G1 + (P1 * C0)
  wire P1_and_C0;
  and (P1_and_C0, P1, C0);
  or (C1, G1, P1_and_C0);  // C1 = G1 OR (P1 AND C0)

  // C2 = G2 + (P2 * C1)
  wire P2_and_C1;
  and (P2_and_C1, P2, C1);
  or (C2, G2, P2_and_C1);  // C2 = G2 OR (P2 AND C1)

  // C3 = G3 + (P3 * C2)
  wire P3_and_C2;
  and (P3_and_C2, P3, C2);
  or (C3, G3, P3_and_C2);  // C3 = G3 OR (P3 AND C2)

  // Sum logic (S = P XOR C)
  xor (S[0], P0, Cin);    // S[0] = P0 XOR Cin
  xor (S[1], P1, C0);     // S[1] = P1 XOR C0
  xor (S[2], P2, C1);     // S[2] = P2 XOR C1
  xor (S[3], P3, C2);     // S[3] = P3 XOR C2

endmodule