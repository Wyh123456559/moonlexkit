# Changelog

## 0.3.0 - 2026-07-18

- Added configurable keyword classification, extended numeric literals, and
  nested block-comment scanning.
- Added recoverable configuration-DSL assignment parsing and its test coverage.
- Updated README, roadmap, benchmark evidence, executable package metadata,
  and OSC 2026 CI gates for MoonBit 0.10.4.

## 0.2.0

- 正式发布可诊断词法扫描与最小 Token 变化区间。
- 28 项测试覆盖扫描、恢复、位置、序列化和差异行为。
- 增加 10,000 行确定性工作负载与四后端 CI。
- 修复公开中文文档乱码并明确社区项目边界。

## 0.1.1 - 2026-06-16

- 修复交叉嵌套分隔符漏报，并把未闭合诊断定位到实际起始符号。
- 完整转义 JSON 低位控制字符。
- CI 扩展为 Native、JavaScript、Wasm 和 Wasm-GC 四后端矩阵。
- 增加 Token 流最小变更范围计算和稳定 JSON 报告。
- 增加 10,000 行确定性扫描与单点编辑差异工作负载。
- 补充与 MoonBit 社区已有 lexer / parser 项目的关系说明。
- 增加字符串字面量扫描和未闭合字符串诊断。
- 增加括号不平衡诊断，提供轻量错误恢复提示。
- 增加 `SourcePosition`、`position_at` 和 `Token::start_position`。
- 增加 `TokenStats` 与 `ScanSummary`，用于解释 token 流和诊断数量。
- 更新 README 与公开开发跟踪文档，强化“Token 流诊断与轻量解析基础库”定位。

## 0.1.0 - 2026-06-10

- 初始化 MoonLexKit 项目结构
- 添加 Token、LexerConfig、TokenStream、Diagnostic、LexResult
- 实现 identifier、number、symbol、whitespace、comment 扫描
- 支持双字符符号和行注释 trivia
- 添加 JSON 导出和 CLI 演示
- 添加 MoonBit 测试、CI、Issue 模板和 PR 模板
