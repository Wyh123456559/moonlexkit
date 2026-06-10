# MoonLexKit

MoonLexKit 是一个面向 MoonBit 生态的词法扫描与轻量解析基础库。项目目标是为配置语言、DSL、教学编译器、代码格式化器、语法高亮、静态检查和 IDE 插件提供可复用的 tokenizer、token stream、诊断和小型 parser helper。

## 定位

MoonLexKit 不绑定某一种具体语言，也不依赖浏览器、文件系统或命令行 IO。核心库只处理字符串、token、跨度和诊断，保持后端中立，便于编译到 WebAssembly、JavaScript 和 Native 目标。

## 当前能力

- 扫描 identifier、number、symbol、whitespace、comment、unknown、end token
- 支持常见双字符符号：`==`、`!=`、`<=`、`>=`、`->`、`=>`
- 支持行注释 `// comment`，并把空白与注释统一视为 trivia
- 通过 `LexerConfig` 控制是否保留 trivia、是否生成 end token
- 提供 `TokenStream` 的 current、advance、matches_kind、consume_kind
- 提供未知字符诊断和 Token JSON 导出
- 附带 CLI JSON 演示、测试和 GitHub Actions CI

## 快速开始

```bash
moon test
moon run cmd/main
```

```moonbit
let config = @moonlexkit.LexerConfig::new(keep_trivia=true)
let tokens = @moonlexkit.scan("answer = 42 // demo", config~)
let json = @moonlexkit.tokens_to_json(tokens)
```

## 设计原则

- 通用：用户可以把它嵌入自己的 DSL、配置文件或工具链
- 干净：核心库不依赖平台 API，不把 CLI 行为污染进算法层
- 可测：每个行为通过 MoonBit 测试覆盖，CI 在 push 和 PR 上自动运行
- 可追踪：功能路线、工单、合并请求和更新日志围绕公开仓库持续沉淀
