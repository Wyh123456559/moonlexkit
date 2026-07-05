# MoonLexKit 与已有 MoonBit lexer 项目的关系

## 背景

初审意见指出：MoonBit 社区已有非常多 lexer 项目，需要至少说明 MoonLexKit 与它们的异同。

## 已有项目类型

MoonBit 生态中与 lexer / parser 有关的项目大致可以分为三类：

1. 生成器类：例如官方 `moonlex`，重点是根据词法规则生成 lexer。
2. 语言实现类：例如 `moonbitlang/parser`，重点是 MoonBit 语言自身的 lexer、parser 和 AST。
3. 具体格式类：例如面向 JSON、SQL、TOML 或某个 DSL 的 parser，重点是解析特定语法。

## MoonLexKit 的边界

MoonLexKit 不做 lexer generator，不复刻 MoonBit 语言 parser，也不绑定某个具体语言格式。项目边界是：

- 通用轻量 tokenizer
- TokenStream 游标工具
- 源码 offset 到 line/column 的位置映射
- 未知字符、未闭合字符串和括号不平衡诊断
- TokenStats 与 ScanSummary，用于调试、测试和 IDE 原型
- Token 流前后缀差异，用于编辑器增量更新和格式化器回归
- JSON 输出，便于 CLI、可视化和差异测试

## 独立价值

MoonLexKit 更适合作为小型 DSL、配置语言、教学编译器和工具原型的起步库。它不像生成器那样要求用户先学习规则语言，也不像完整 parser 那样绑定复杂语法树，而是提供“扫描结果可解释、诊断可复用、Token 流可测试”的基础层。

## 后续计划

- 增加关键字表和 token kind 扩展策略。
- 增加字符串转义诊断和错误恢复测试。
- 扩展 token 流差异为按行重扫描窗口，服务格式化器和静态检查工具。
- 增加大输入扫描 benchmark 和 WebAssembly 演示。
