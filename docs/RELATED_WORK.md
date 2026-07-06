# 与 MoonBit 社区 lexer 项目的关系

## 已有项目类型

MoonBit 生态中的 lexer / parser 项目大致分为：

1. 生成器，例如官方 `moonlex`，根据规则生成 lexer。
2. 语言实现，例如 `moonbitlang/parser`，解析 MoonBit 语言自身并构造 AST。
3. 格式专用解析器，例如面向 JSON、SQL、TOML 或特定 DSL 的 parser。

## MoonLexKit 的边界

MoonLexKit 不做 lexer generator，不复刻 MoonBit 语言 parser，也不绑定具体格式。它提供小型工具可直接组合的基础层：

- 通用轻量 tokenizer 与可选 trivia。
- offset 到 line/column 的位置映射。
- 未知字符、字符串和分隔符结构诊断。
- `TokenStats` 与 `ScanSummary` 可观测摘要。
- 基于最长公共前后缀的最小 Token 变化区间。
- JSON 输出和四后端确定性验证。

## 独立价值

生成器解决“如何从规则生成扫描器”，完整 parser 解决“如何构造特定语言语法树”。MoonLexKit 解决的是另一层问题：让小型工具快速获得可解释扫描、可复用诊断和可验证 Token 变化范围。它适合作为格式化器、编辑器增量更新、教学编译器和 DSL 原型的起步库，也可以为后续生成器或 parser 提供测试与诊断组件。
