# Changelog

## 0.1.1 - 2026-06-16

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
