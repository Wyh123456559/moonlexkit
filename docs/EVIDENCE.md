# 验收证据

## 自动化检查

```bash
moon fmt --check
moon check --target all
moon test --target wasm
moon test --target wasm-gc
moon run cmd/main --target js
moon run bench/main --target js
moon package --list
moon info
git diff --check
```

当前 28 项测试覆盖扫描配置、字符串转义、注释 trivia、双字符符号、TokenStream、源码位置、诊断恢复、交叉分隔符、JSON 控制字符、统计摘要和 Token 流差异。

## 固定工作负载

`bench/main` 生成 10,000 行 DSL 文本，完整扫描两份输入，并在第 5,000 行制造单点修改。输出源码长度、Token 数量、诊断数量和最小差异范围，用于比较不同 MoonBit 后端是否得到相同结果。

该工作负载用于规模与确定性回归，不以单台机器耗时宣称跨平台速度。

固定输出：

```text
lines=10000
source_units=237780
tokens=80001
diagnostics=0
unchanged_prefix=40004
unchanged_suffix=39996
removed_tokens=1
inserted_tokens=1
```

单点修改只产生一个删除 Token 和一个插入 Token，证明差异计算不会把整个文件误判为变化。
