# S7-200 以及 SMART 工程文件格式

[English](README.md)

> 主仓库： https://github.com/wpyoga/s7-200-smart-project-file
>
> 请在github上提交Issue和PR，或者向[工控人家园论坛wpyoga](http://www.ymmfa.com/u-gkuid-616507.html)发短消息。

本项目旨在对 **S7-200** 以及 **SMART** 系列 PLC 的**工程文件结构和存储格式**进行分析。

更具体地说，这是 **STEP 7-Micro/WIN SMART** （以及**STEP 7-Micro/WIN**） 所使用的工程文件格式。

---

## 项目目标

### 当前主要目标
- 分析工程文件的内部结构与数据组织方式
- 使工程文件能够兼容 git 进行版本控制
  - 将工程文件格式转换为 JSON 或其他标准格式
  - 从 JSON 文件生成工程文件
  - 可通过 git 提交钩子（commit hooks）实现
  - 按道理，被生成的工程文件与原工程文件100%相符
- 生成可直接复制粘贴的符号表（Symbol Table）和数据块（Data Block）内容

### 可选目标（Nice-to-have/非必须）
- 在程序块（Program Block）与 SCL 之间进行双向转换
- 将程序块转换为 AWL

---

## 本项目不涉及以下内容

- 任何形式的密码破解或绕过工程文件保护机制
- 获取或还原用于保护工程文件的任何密码
- 与西门子（Siemens AG）在产品或工具层面的竞争行为

---

## 文件格式文档

- [Micro/WIN SMART V2.x 工程文件格式](doc/MicroWIN%20SMART%20V2.x%20file%20format.md)
- [Micro/WIN SMART V3.x 工程文件格式](doc/MicroWIN%20SMART%20V3.x%20file%20format.md)

---

## 一些发现与技术说明

- 工程文件最初看起来像是“文件头 + 加密的二进制数据”。
  实际分析表明，其中的 `0x78 0x9c` 字节是 **zlib 压缩数据的文件头**。

---

## 已知限制与阻碍

- 目前尚未获取 STEP 7-Micro/WIN SMART v1.0 的安装包或工程样本，
  因此对**最早版本**工程文件格式的分析仍然不完整。

---

## 版本范围说明

当前分析主要覆盖以下版本：
- STEP 7-Micro/WIN SMART V2.x
- STEP 7-Micro/WIN SMART V3.x

对于 v1.0 版本，仍存在已知信息缺口。

---

## 适用人群

本项目主要面向以下读者：
- 工业自动化工程师
- PLC 软件工具或工程辅助工具开发者
- 对 STEP 7-Micro/WIN SMART 工程文件结构感兴趣的研究人员

---

## 说明与声明

本项目仅用于**工程文件结构与存储格式的研究和学习**，
不涉及任何形式的破解、绕过保护机制或获取受保护信息的行为。

本项目与西门子（Siemens AG）不存在任何隶属、合作或授权关系。

---

## 趣闻（Trivia）

- S7-200 SMART 源自 S7-200 系列 PLC。
  - 最早的工程文件模板（使用至 v2.8.2.1）中，
    甚至内嵌了版本号 `4.0.0.46`。
- S7-200 SMART 最初面向新兴市场（中国和印度）开发。
  随着中国（以及在较小程度上的印度）工业设备出口到全球，
  该 PLC 也逐渐在世界各地得到应用。
- 最初的文件结构分析参考并使用了 **French Cafe** 技术：
  https://download.samba.org/pub/tridge/misc/french_cafe.txt
- SMART V2 和 V3 反工程工作进行了一大半，发现V2的文件格式与老200的文件格式没有很多差别。
  除了preamble略微不同，Program Block部分接近100%一样。
