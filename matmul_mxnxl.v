`timescale 1ns / 1ps

module matmul_mxnxl #(parameter W=8, M=4, N=3, L=3)
(
    input clk,
    input rstn,
    input [M*N*W-1:0] transformation_mtx,        // G(MxN)
    input [N*L*W-1:0] input_mtx,                 // g(NxL)
    output [M*L*W-1:0] result_mtx                // Gg(MxL)
);

always @(posedge clk) begin
    if(!rstn) begin
        transformation_mtx <= 0;
        input_mtx <= 0;
        result_mtx <= 0;
    end
end

integer m, n, l;

    begin
        for (m=0; m<M; m=m+1) begin
            for (l=0; l<L; l=l+1) begin
                result_mtx[m*L*W + l*W +: W] <= 0;
                for (n=0; n<N; n=n+1) begin
                    result_mtx[m*L*W + l*W +: W] <= result_mtx[m*L*W + l*W +: W] + transformation_mtx[m*N*W + n*W +: W] * input_mtx[n*L*W + l*W +: W];
                end
            end
        end
    end

endmodule
