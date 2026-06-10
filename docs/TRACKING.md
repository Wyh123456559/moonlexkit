# 公开开发跟踪

本项目按公开仓库持续开发方式推进，核心证据包括提交记录、Issue、Pull Request、CHANGELOG 和 CI。

## 当前提交主题

- 基础骨架
- 字符分类器
- 扫描配置
- 基础扫描器
- TokenStream
- 诊断结果
- 轻量解析辅助
- 双字符符号
- 行注释 trivia
- JSON 导出
- CLI 演示
- CI 与协作模板

## 后续工单建议

1. 支持字符串字面量和转义序列
2. 支持关键字表和 token kind 扩展策略
3. 增加大输入扫描 benchmark
4. 增加 WebAssembly 示例

## 合并请求建议

后续开发建议每个功能走独立分支和 Pull Request，例如：

- `feat/string-literals`
- `feat/keyword-table`
- `bench/scanner-throughput`
- `demo/wasm-tokenizer`
