module tb_Systolic_Array_Random();

localparam WIDTH = 8;
localparam ARRAY_SIZE = 4; 
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

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_Systolic_Array_Random);

    clk = 0;
    rst = 0;
    in1 = 0;
    in2 = 0;
    en  = 0;

    #10
    rst = 1;
    #10
    rst = 0;

    // 1. 生成随机矩阵 (种子由外部传入)
    generate_random_matrices();

    // 2. 写入输入文件
    write_inputs_to_file();

    // 3. 计算正确答案
    calculate_golden();

    #10
    en  = 1;
    
    #300; 
    
    // 4. 打印结果
    print_matrices();
    
    // 5. 写入结果文件
    write_results_to_file();
    
    $finish;
end

// ==========================================
// 任务: 生成随机矩阵 (使用命令行传入的种子)
// ==========================================
task generate_random_matrices;
    integer i, j;
    reg signed [WIDTH-1:0] rand_val;
    integer seed;
    begin
        $display("--------------------------------------------");
        
        // 尝试获取命令行参数 +SEED=xxx
        // 如果没有提供，默认使用种子 1
        if ($value$plusargs("SEED=%d", seed)) begin
            $display("检测到外部种子: %0d", seed);
        end else begin
            seed = 1;
            $display("未检测到外部种子，使用默认种子: 1");
            $display("提示: 运行时可使用 +SEED=$(date +%s) 传入随机种子");
        end
        
        $display("正在生成 %0dx%0d 的随机矩阵 (位宽 %0d)...", ARRAY_SIZE, ARRAY_SIZE, WIDTH);
        $display("--------------------------------------------");
        
        // 生成矩阵 1
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
                // 注意: $random(seed) 会更新 seed 的值
                rand_val = $random(seed); 
                in1[(i*ARRAY_SIZE+j)*WIDTH +:WIDTH] = rand_val;
            end
        end
        
        // 生成矩阵 2
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
                rand_val = $random(seed);
                in2[(i*ARRAY_SIZE+j)*WIDTH +:WIDTH] = rand_val;
            end
        end
    end
endtask

// ==========================================
// 任务: 将输入矩阵覆盖写入文件 ("w" 模式)
// ==========================================
task write_inputs_to_file;
    integer i, j;
    begin
        file_handle = $fopen("test.txt", "w");
        if (file_handle == 0) begin
            $display("错误: 无法打开 test.txt 文件进行写入");
            $finish;
        end

        $fdisplay(file_handle, "// =============================================");
        $fdisplay(file_handle, "// Testbench 自动生成的输入矩阵");
        $fdisplay(file_handle, "// 规模: %0dx%0d, 位宽: %0d", ARRAY_SIZE, ARRAY_SIZE, WIDTH);
        $fdisplay(file_handle, "// =============================================");

        $fdisplay(file_handle, "\n// --- 输入矩阵 1 (Input Matrix 1) ---");
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
                $fwrite(file_handle, "%4d ", $signed(in1[(i*ARRAY_SIZE+j)*WIDTH +:WIDTH]));
            end
            $fdisplay(file_handle, "");
        end

        $fdisplay(file_handle, "\n// --- 输入矩阵 2 (Input Matrix 2) ---");
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
                $fwrite(file_handle, "%4d ", $signed(in2[(i*ARRAY_SIZE+j)*WIDTH +:WIDTH]));
            end
            $fdisplay(file_handle, "");
        end
        
        $fclose(file_handle);
        $display("输入矩阵已覆盖写入 test.txt");
    end
endtask

// ==========================================
// 任务: 计算预期结果 (软件模拟)
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
                    val_a = in1[(i*ARRAY_SIZE+k)*WIDTH +: WIDTH];
                    val_b = in2[(k*ARRAY_SIZE+j)*WIDTH +: WIDTH];
                    sum = sum + val_a * val_b;
                end
                golden_result[i*ARRAY_SIZE+j] = sum;
            end
        end
    end
endtask

// ==========================================
// 任务: 将结果追加写入文件 ("a" 模式)
// ==========================================
task write_results_to_file;
    integer i, j;
    integer errors;
    reg signed [RES_WIDTH-1:0] hw_val;
    reg signed [RES_WIDTH-1:0] golden_val;
    begin
        file_handle = $fopen("test.txt", "a");
        if (file_handle == 0) begin
            $display("错误: 无法打开 test.txt 文件进行追加写入");
            $finish;
        end
        
        $fdisplay(file_handle, "\n// =============================================");
        $fdisplay(file_handle, "// 运算结果与对比");
        $fdisplay(file_handle, "// =============================================");

        $fdisplay(file_handle, "\n// --- 硬件计算结果 (Hardware Result) ---");
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
                hw_val = result[(i*ARRAY_SIZE+j)*RES_WIDTH +: RES_WIDTH];
                $fwrite(file_handle, "%6d ", hw_val);
            end
            $fdisplay(file_handle, "");
        end
        
        $fdisplay(file_handle, "\n// --- 正确答案 (Golden Reference) ---");
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
                golden_val = golden_result[i*ARRAY_SIZE+j];
                $fwrite(file_handle, "%6d ", golden_val);
            end
            $fdisplay(file_handle, "");
        end

        $fdisplay(file_handle, "\n// --- 对比报告 (Comparison Report) ---");
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
            $fdisplay(file_handle, "RESULT: FAIL (%0d errors found)", errors);
        
        $fclose(file_handle);
        $display("运算结果已追加写入 test.txt");
    end
endtask

// ==========================================
// 任务: 控制台完整打印显示
// ==========================================
task print_matrices;
    integer i, j;
    reg signed [RES_WIDTH-1:0] hw_val;
    reg signed [RES_WIDTH-1:0] golden_val;
    integer errors;
    begin
        $display("\n========================================");
        $display("          仿真完成 - 结果概览");
        $display("========================================");
        
        // 1. 显示输入矩阵 1
        $display("\n[输入] Matrix 1 (In1):");
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
             $write(" Row %0d: ", i);
             for(j=0; j<ARRAY_SIZE; j=j+1) 
                $write("%4d ", $signed(in1[(i*ARRAY_SIZE+j)*WIDTH +:WIDTH]));
             $display("");
        end

        // 2. 显示输入矩阵 2
        $display("\n[输入] Matrix 2 (In2):");
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
             $write(" Row %0d: ", i);
             for(j=0; j<ARRAY_SIZE; j=j+1) 
                $write("%4d ", $signed(in2[(i*ARRAY_SIZE+j)*WIDTH +:WIDTH]));
             $display("");
        end
        
        // 3. 显示硬件结果
        $display("\n[输出] 硬件计算结果 (Hardware):");
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            $write(" Row %0d: ", i);
            for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
                $write("%6d ", $signed(result[(i*ARRAY_SIZE+j)*RES_WIDTH +: RES_WIDTH]));
            end
            $display("");
        end

        // 4. 显示参考结果
        $display("\n[输出] 预期正确结果 (Reference):");
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            $write(" Row %0d: ", i);
            for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
                $write("%6d ", golden_result[i*ARRAY_SIZE+j]);
            end
            $display("");
        end

        // 5. 对比结论
        $display("\n[状态] 自动对比报告:");
        errors = 0;
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
                hw_val = result[(i*ARRAY_SIZE+j)*RES_WIDTH +: RES_WIDTH];
                golden_val = golden_result[i*ARRAY_SIZE+j];
                if (hw_val !== golden_val) errors = errors + 1;
            end
        end

        if (errors == 0) $display("--> PASS: 硬件输出与预期结果完全匹配！");
        else             $display("--> FAIL: 发现 %0d 个错误！详情请查看 test.txt", errors);
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