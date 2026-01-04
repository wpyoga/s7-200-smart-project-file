# S7-200 SMART 工程文件格式

本项目旨在对 S7-200 SMART 系列 PLC 的项目文件格式进行逆向工程分析。

更具体地说，这是 **STEP 7-Micro/WIN SMART** 所使用的项目文件格式。

## 项目目标

### 当前主要目标：
- 对项目文件格式进行逆向工程分析  
- 将项目文件格式转换为 JSON 或其他标准格式  
- 从 JSON 文件生成项目文件  
- 生成可直接复制粘贴的符号表（Symbol Tables）和数据页（Data Pages）输出  
- 使项目文件能够兼容 git 进行版本控制  
  - 这可以通过使用 git 的 commit hooks 来实现  

### 可选（锦上添花）的目标：
- 将程序块转换为 SCL，或从 SCL 转换回程序块  
- 将程序块转换为 AWL  

## 非目标（明确不做的事情）

我们**不打算**：
- 破解或绕过任何项目文件的密码保护机制  
- 获取用于保护项目文件的任何密码  
- 以任何形式与西门子（Siemens）进行竞争  

## 文件格式文档

- [Micro/WIN SMART V2.x 文件格式](MicroWIN%20SMART%20V2.x%20file%20format.md)
- [Micro/WIN SMART V3.x 文件格式](MicroWIN%20SMART%20V3.x%20file%20format.md)

## 一些发现与洞察

- 项目文件最初看起来像是“文件头 + 加密的二进制数据”。  
  实际上，文件中的 `0x78 0x9c` 字节是 **zlib 压缩格式的文件头**。

## 当前阻碍

- 我没有 STEP 7-Micro/WIN SMART v1.0 的安装包或副本，因此无法对**最早版本**的项目文件格式进行更深入的分析。

## 趣闻（Trivia）

- S7-200 SMART 源自 S7-200。
  - 最早的项目文件格式（作为项目模板使用，直到 v2.8.2.1）中，甚至编码了版本号 `4.0.0.46`。
- S7-200 SMART 最初是为新兴市场（中国和印度）开发的。  
  随着中国（以及在较小程度上的印度）将工业设备出口到全球，该 PLC 也逐渐传播到了世界各地。
- 最初的逆向工程工作参考并使用了 **French Cafe** 技术：  
  https://download.samba.org/pub/tridge/misc/french_cafe.txt
