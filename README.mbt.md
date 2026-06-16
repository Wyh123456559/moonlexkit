# MoonLexKit

MoonLexKit 是一个面向 MoonBit 生态的词法扫描结果诊断与轻量解析基础库。项目目标不是替代官方 lexer generator 或某个语言的完整 parser，而是为配置语言、DSL、教学编译器、代码格式化器、语法高亮、静态检查和 IDE 插件提供可复用的 tokenizer、token stream、源位置映射、诊断摘要和小型 parser helper。

## 与已有 lexer 项目的关系

MoonBit 社区已经存在较多 lexer / parser 项目，例如官方 `moonlex` lexer generator、`moonbitlang/parser` 中的 MoonBit 语言 lexer/parser，以及若干面向 JSON、SQL、TOML 或特定 DSL 的解析器。MoonLexKit 不做生成器，不绑定 MoonBit 语言语法，也不竞争某个具体语言 parser。

MoonLexKit 的边界是“轻量扫描器工具箱 + Token 流诊断层”：用少量通用 token、可解释 span、line/column 映射、TokenStats、ScanSummary 和错误恢复诊断，帮助库作者快速构建小型 DSL、配置语言和教学编译器原型。

## 定位

MoonLexKit 不绑定某一种具体语言，也不依赖浏览器、文件系统或命令行 IO。核心库只处理字符串、token、跨度和诊断，保持后端中立，便于编译到 WebAssembly、JavaScript 和 Native 目标。

## 当前能力

- 扫描 identifier、number、symbol、whitespace、comment、unknown、end token
- 扫描字符串字面量，并诊断未闭合字符串
- 支持常见双字符符号：`==`、`!=`、`<=`、`>=`、`->`、`=>`
- 支持行注释 `// comment`，并把空白与注释统一视为 trivia
- 通过 `LexerConfig` 控制是否保留 trivia、是否生成 end token
- 提供 `TokenStream` 的 current、advance、matches_kind、consume_kind
- 提供未知字符、未闭合字符串、括号不平衡诊断
- 提供 `position_at` 与 `Token::start_position`，支持 offset 到 line/column 的映射
- 提供 `TokenStats` 与 `ScanSummary`，输出 token 流摘要和诊断数量
- 提供 Token JSON、统计 JSON 和扫描摘要 JSON 导出
- 附带 CLI JSON 演示、测试和 GitHub Actions CI

## 快速开始

```bash
moon test
moon run cmd/main
```

```moonbit nocheck
///|
let config = @moonlexkit.LexerConfig::new(keep_trivia=true)

///|
let tokens = @moonlexkit.scan("answer = 42 // demo", config~)

///|
let json = @moonlexkit.tokens_to_json(tokens)

///|
let result = @moonlexkit.scan_with_diagnostics("name = \"Moon\"", config~)

///|
let summary = result.summary("name = \"Moon\"")
```

## 设计原则

- 通用：用户可以把它嵌入自己的 DSL、配置文件或工具链
- 干净：核心库不依赖平台 API，不把 CLI 行为污染进算法层
- 可测：每个行为通过 MoonBit 测试覆盖，CI 在 push 和 PR 上自动运行
- 可追踪：功能路线、工单、合并请求和更新日志围绕公开仓库持续沉淀
- 差异化：不做 lexer generator，不做完整语言 parser，而是聚焦 token 流诊断和轻量解析辅助

更完整的关系说明见 [docs/RELATED_WORK.md](docs/RELATED_WORK.md)。
