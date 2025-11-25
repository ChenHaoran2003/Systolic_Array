module tb_Systolic_Array();

localparam WIDTH = 8;
localparam ARRAY_SIZE = 5;
// 定义结果位宽：2*WIDTH (乘法扩位) + log2(ARRAY_SIZE) (累加扩位)
localparam RES_WIDTH = 2*WIDTH + $clog2(ARRAY_SIZE);

reg clk;
reg rst;
reg en;
reg [WIDTH*ARRAY_SIZE*ARRAY_SIZE-1:0] in1;
reg [WIDTH*ARRAY_SIZE*ARRAY_SIZE-1:0] in2;
wire [RES_WIDTH*ARRAY_SIZE*ARRAY_SIZE-1:0] result;

// 用于存储正确答案的数组
reg signed [RES_WIDTH-1:0] golden_result [0:ARRAY_SIZE*ARRAY_SIZE-1];

integer file_handle;
integer read_result;

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_Systolic_Array);

    clk = 0;
    rst = 0;
    in1 = 0;
    in2 = 0;
    en  = 0;
    #10
    rst = 1;
    #10
    rst = 0;
    
    read_matrices_from_file();
    
    // 1. 在硬件运行前，先算出正确答案
    calculate_golden();
    
    #10
    en  = 1;
    #300
    
    // 2. 打印到控制台
    print_matrices();
    
    // 3. 写入到文件
    write_results_to_file();
    
    $finish;
end

// ==========================================
// 任务: 计算预期结果 (软件模拟矩阵乘法)
// ==========================================
task calculate_golden;
    integer i, j, k;
    reg signed [WIDTH-1:0] val_a;
    reg signed [WIDTH-1:0] val_b;
    reg signed [RES_WIDTH-1:0] sum;
    begin
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
                sum = 0;
                for (k = 0; k < ARRAY_SIZE; k = k + 1) begin
                    // 提取 A[i][k]
                    val_a = in1[(i*ARRAY_SIZE+k)*WIDTH +: WIDTH];
                    // 提取 B[k][j]
                    val_b = in2[(k*ARRAY_SIZE+j)*WIDTH +: WIDTH];
                    sum = sum + val_a * val_b;
                end
                golden_result[i*ARRAY_SIZE+j] = sum;
            end
        end
    end
endtask

// ==========================================
// 任务: 从文件读取输入矩阵
// ==========================================
task read_matrices_from_file;
    integer i, j;
    integer value1, value2;
    reg signed [WIDTH-1:0] temp1, temp2;
    begin
        file_handle = $fopen("test.txt", "r");
        if (file_handle == 0) begin
            $display("错误: 无法打开test.txt文件");
            $finish;
        end
        
        // 读取第一个矩阵
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
                read_result = $fscanf(file_handle, "%d", value1);
                temp1 = value1;
                in1[(i*ARRAY_SIZE+j)*WIDTH +:WIDTH] = temp1;
            end
        end
        
        // 读取第二个矩阵
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
                read_result = $fscanf(file_handle, "%d", value2);
                temp2 = value2;
                in2[(i*ARRAY_SIZE+j)*WIDTH +:WIDTH] = temp2;
            end
        end
        
        $fclose(file_handle);
    end
endtask

// ==========================================
// 任务: 将结果分开写入文件
// ==========================================
task write_results_to_file;
    integer i, j;
    integer errors;
    reg signed [RES_WIDTH-1:0] hw_val;
    reg signed [RES_WIDTH-1:0] golden_val;
    begin
        file_handle = $fopen("test.txt", "a");
        if (file_handle == 0) begin
            $display("错误: 无法打开test.txt文件进行写入");
        end
        
        // --- 写入硬件结果区块 ---
        $fdisplay(file_handle, "\n// -----------------------------");
        $fdisplay(file_handle, "// 硬件计算结果 (Hardware Result)");
        $fdisplay(file_handle, "// -----------------------------");
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
                hw_val = result[(i*ARRAY_SIZE+j)*RES_WIDTH +: RES_WIDTH];
                $fwrite(file_handle, "%5d ", hw_val);
            end
            $fdisplay(file_handle, "");
        end
        
        // --- 写入正确答案区块 ---
        $fdisplay(file_handle, "\n// -----------------------------");
        $fdisplay(file_handle, "// 正确答案 (Golden Reference)");
        $fdisplay(file_handle, "// -----------------------------");
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
                golden_val = golden_result[i*ARRAY_SIZE+j];
                $fwrite(file_handle, "%5d ", golden_val);
            end
            $fdisplay(file_handle, "");
        end

        // --- 写入对比结论 ---
        $fdisplay(file_handle, "\n// -----------------------------");
        $fdisplay(file_handle, "// 对比报告 (Comparison Report)");
        $fdisplay(file_handle, "// -----------------------------");
        errors = 0;
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
                hw_val = result[(i*ARRAY_SIZE+j)*RES_WIDTH +: RES_WIDTH];
                golden_val = golden_result[i*ARRAY_SIZE+j];
                
                if (hw_val !== golden_val) begin
                    errors = errors + 1;
                    $fdisplay(file_handle, "FAIL: Row %0d Col %0d -> HW: %d, Ref: %d", i, j, hw_val, golden_val);
                end
            end
        end

        if (errors == 0)
            $fdisplay(file_handle, "RESULT: PASS (All Correct)");
        else
            $fdisplay(file_handle, "RESULT: FAIL (%0d errors)", errors);
        
        $fclose(file_handle);
        $display("结果已写入 test.txt");
    end
endtask

// ==========================================
// 任务: 控制台打印显示 (分开显示)
// ==========================================
task print_matrices;
    integer i, j;
    reg signed [RES_WIDTH-1:0] hw_val;
    reg signed [RES_WIDTH-1:0] golden_val;
    integer errors;
    begin
        $display("\n========================================");
        $display("          矩阵运算结果概览");
        $display("========================================");
        
        // 1. 显示硬件结果
        $display("\n[1] 硬件计算结果 (Hardware):");
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            $write("  Row %0d: ", i);
            for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
                $write("%5d ", $signed(result[(i*ARRAY_SIZE+j)*RES_WIDTH +: RES_WIDTH]));
            end
            $display("");
        end
        
        // 2. 显示正确答案
        $display("\n[2] 正确答案 (Golden Reference):");
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            $write("  Row %0d: ", i);
            for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
                $write("%5d ", golden_result[i*ARRAY_SIZE+j]);
            end
            $display("");
        end
        
        // 3. 自动校验
        errors = 0;
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
                hw_val = result[(i*ARRAY_SIZE+j)*RES_WIDTH +: RES_WIDTH];
                golden_val = golden_result[i*ARRAY_SIZE+j];
                if (hw_val !== golden_val) errors = errors + 1;
            end
        end

        $display("\n[3] 对比结论:");
        if (errors == 0)
            $display("  --> PASS: 硬件计算结果完全正确");
        else
            $display("  --> FAIL: 发现 %0d 个错误，请检查 test.txt 获取详情。", errors);
            
        $display("========================================\n");
    end
endtask

always begin
    #5
    clk = ~clk;
end

Systolic_Array #(
    .WIDTH      (WIDTH),
    .ARRAY_SIZE (ARRAY_SIZE)
) u_Systolic_Array (
    .clk    (clk),
    .rst    (rst),
    .en     (en),
    .in1    (in1),
    .in2    (in2),
    .result (result)
);

endmodule