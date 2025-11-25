# 可配置二维脉动阵列（Configurable Systolic Array）

## 项目组成：
本项目有两个版本，其中`version1`版本是可配置阵列大小与位宽的有符号数脉动阵列，`version2`版本是固定4x4大小的8bit有符号数脉动阵列。两个版本的项目子目录结构一致。

```
version1
|-- tb_Systolic_Array.v：testbench文件
|-- tb_Systolic_Array_Random.v：随机生成测试矩阵的testbench文件，使用此文件作为testbench会覆盖`test.txt`文件内容
|-- Systolic_Array.v：脉动阵列RTL
|-- Processing_Element.v：处理单元RTL
|-- test.txt：存放仿真时输入矩阵，保存仿真结果
|-- example.txt：可供参考的矩阵

version2
|-- tb_Systolic_Array.v：testbench文件
|-- tb_Systolic_Array_Random.v：随机生成测试矩阵的testbench文件，使用此文件作为testbench会覆盖`test.txt`文件内容
|-- Systolic_Array.v：脉动阵列RTL
|-- Processing_Element.v：处理单元RTL
|-- test.txt：存放仿真时输入矩阵，保存仿真结果
|-- example.txt：可供参考的矩阵
```

## 仿真环境：
- Ubuntu 22.04
- iverilog
- GTKWave

## 仿真流程：

### 安装iverilog与GTKWave
输入命令：
```
sudo apt-get install iverilog
sudo apt-get install gtkwave
```

### 编译文件testbench与RTL生成可执行文件并运行
项目目录中存在两个testbench文件，使用`tb_Systolic_Array.v`时测试的矩阵需要手动输入，使用`tb_Systolic_Array_Random.v`时测试的矩阵会自动生成。

#### 1. 测试数据使用手动设置的矩阵
输入命令：
```
iverilog -o sim -s tb_Systolic_Array tb_Systolic_Array.v Systolic_Array.v Processing_Element.v
```
编译文件后会生成`sim`可执行文件用于仿真。仿真的矩阵数据保存在`test.txt`文件中，因此可以通过修改`test.txt`文件内容修改仿真数据。

输入命令：
```
./sim
```
运行可执行文件时，终端中会输出运行结果，同时所在目录下会生成`wave.vcd`波形文件。此外，仿真结果也会写入至`test.txt`文件中。

#### 2. 测试数据使用随机生成的矩阵
输入命令：
```
iverilog -o sim -s tb_Systolic_Array_Random tb_Systolic_Array_Random.v Systolic_Array.v Processing_Element.v
```
编译文件后会生成`sim`可执行文件用于仿真。仿真的矩阵数据保存在`test.txt`文件中，因此可以通过修改`test.txt`文件内容修改仿真数据。

输入命令：
```
./sim +SEED=$(date +%s)
```
上面的命令中`+SEED=$(date +%s)`的作用是获取系统时间的秒级时间戳，并将其作为随机数种子。运行可执行文件时，终端中会输出运行结果，同时所在目录下会生成`wave.vcd`波形文件。此外，仿真结果也会写入至`test.txt`文件中。

### 查看波形
输入命令：
```
gtkwave wave.vcd
```

### 配置脉动阵列大小与位宽
在`version2`项目中，修改`tb_Systolic_Array.v`文件的：
```
localparam WIDTH = 8;
localparam ARRAY_SIZE = 4;
```
参数即可配置脉动阵列大小与位宽。
修改参数的同时也需要修改`test.txt`文件中的矩阵以满足输入要求。


## 项目说明
本项目的testbench使用了大语言模型进行编写。