#include <stdio.h>
#include <stdint.h> // For fixed-width types like int32_t


void matmul_cpu(int32_t C[2][2], const int32_t A[2][2], const int32_t B[2][2]) {

    C[0][0] = (A[0][0] * B[0][0]) + (A[0][1] * B[1][0]);
    C[0][1] = (A[0][0] * B[0][1]) + (A[0][1] * B[1][1]);
    C[1][0] = (A[1][0] * B[0][0]) + (A[1][1] * B[1][0]);
    C[1][1] = (A[1][0] * B[0][1]) + (A[1][1] * B[1][1]);

}

/**
 * Assumed Instruction: "matmul rd, rs1, rs2"
 * - rd: Not needed
 * - rs1: Register holding the base address of the input matrix A.
 * - rs2: Register holding the base address of the input matrix B.
 *
 */
void matmul_hw_accelerator(int32_t C[2][2], const int32_t A[2][2], const int32_t B[2][2]) {

    __asm__ __volatile__ (
        // The "matmul" instruction.
        // %0 maps to C (rd)
        // %1 maps to A (rs1)
        // %2 maps to B (rs2)
        "matmul %0, %1, %2"
        : 
        : "r" (C), "r" (A), "r" (B)
        : "memory"
    );
}


int main() {
    // 1. Define input matrices
    const int32_t A[2][2] = {
        {1, 2},
        {3, 4}
    };

    const int32_t B[2][2] = {
        {5, 6},
        {7, 8}
    };

    // 2. Define output matrices
    int32_t C_hw[2][2];
    int32_t C_cpu[2][2];
 

    // --- Test CPU only Version ---
    matmul_cpu(C_cpu, A, B);
    
    // --- Test Coprocessor Version ---
    matmul_hw_accelerator(C_hw, A, B);

    while (1);
    return 0;
}
