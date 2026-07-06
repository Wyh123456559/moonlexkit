# MoonLexKit

MoonLexKit 是面向 MoonBit 的词法扫描、诊断恢复与 Token 流差异基础库，适用于小型 DSL、配置语言、格式化器、静态检查器和编辑器原型。

## 核心价值

- 扫描标识符、数字、字符串、注释、空白及常用单双字符符号。
- 可选择保留 trivia，支持格式化和源码重写场景。
- 报告未知字符、未闭合字符串、括号缺失与交叉嵌套。
- 将源码 offset 映射为稳定的行列位置。
- `TokenStream` 提供安全游标与条件消费。
- `diff_tokens` 返回不变前缀、不变后缀及最小变化区间，服务编辑器增量更新。
- JSON、统计摘要和确定性工作负载便于跨后端回归。
- CI 覆盖 Native、JavaScript、Wasm、Wasm-GC。

## 快速验收

```bash
moon fmt --check
moon check --target all
moon test --target wasm
moon test --target wasm-gc
moon run cmd/main --target js
moon run bench/main --target js
```

完整 API 示例见 [README.mbt.md](README.mbt.md)，社区差异见
[docs/RELATED_WORK.md](docs/RELATED_WORK.md)。
