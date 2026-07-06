# xiaoyuzhou-to-article-qwen

把一个小宇宙单集链接交给 Agent，完成这条流程：

```text
小宇宙链接
  → 下载原始音频
  → 上传通义听悟转写
  → 导出完整文字稿
  → 检查开头、中段和结尾
  → 生成结构化 Markdown 播客笔记
```

最终笔记包含内容概括、按讲述顺序拆分的模块、金句摘录、5 分钟看懂版，以及可直接放进 Obsidian 的结论。

这是社区项目，不是阿里云、通义听悟或 Qwen 官方项目。名称中的 `qwen` 表示面向通义/Qwen 使用场景；音频转写由通义听悟完成，内容整理可以由当前运行 skill 的模型执行。

## 安装

### 方法一：让 Codex 自动安装

在 Codex 中直接发送：

```text
请帮我安装这个 skill：
https://github.com/yxqhuqin222-star/xiaoyuzhou-to-article-qwen/tree/main/xiaoyuzhou-to-article-qwen
```

如果已经启用了 `$skill-installer`，也可以输入：

```text
$skill-installer install https://github.com/yxqhuqin222-star/xiaoyuzhou-to-article-qwen/tree/main/xiaoyuzhou-to-article-qwen
```

安装完成后重新打开 Codex 会话，让新 skill 被重新加载。

### 方法二：手动安装

```bash
git clone https://github.com/yxqhuqin222-star/xiaoyuzhou-to-article-qwen.git
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
cp -R xiaoyuzhou-to-article-qwen/xiaoyuzhou-to-article-qwen \
  "${CODEX_HOME:-$HOME/.codex}/skills/"
```

安装后的目录应为：

```text
~/.codex/skills/xiaoyuzhou-to-article-qwen/
├── SKILL.md
├── agents/openai.yaml
├── references/output-format.md
└── scripts/prepare_audio.sh
```

可以运行下面两条命令确认安装：

```bash
test -f "${CODEX_HOME:-$HOME/.codex}/skills/xiaoyuzhou-to-article-qwen/SKILL.md"
bash "${CODEX_HOME:-$HOME/.codex}/skills/xiaoyuzhou-to-article-qwen/scripts/prepare_audio.sh" --help
```

看到脚本用法说明，表示文件已经放到正确位置。

## 安装依赖

本 skill 需要：

- [podpull](https://github.com/xiaoleiy/podpull)：下载小宇宙音频
- `ffprobe`：验证音频格式和时长，随 FFmpeg 提供
- Chrome：操作通义听悟网页
- 可正常使用的通义听悟账号

macOS 可用 Homebrew 安装：

```bash
brew install xiaoleiy/tap/podpull
brew install ffmpeg
```

验证依赖：

```bash
podpull --version
ffprobe -version
```

其他系统请参考 podpull 和 FFmpeg 的上游安装文档。当前版本已在 Apple Silicon macOS 上用一段约 75 分钟的真实小宇宙节目完成端到端验证，Windows 和 Linux 尚未完成完整验证。

## 使用

### 直接发送链接

重新打开 Codex 会话后，发送小宇宙单集链接即可：

```text
https://www.xiaoyuzhoufm.com/episode/...
```

链接中需要包含 `/episode/`。播客主页、节目列表页不属于支持范围。

### 显式调用

如果没有自动触发，可以显式指定 skill：

```text
Use $xiaoyuzhou-to-article-qwen to process:
https://www.xiaoyuzhoufm.com/episode/...
```

也可以用中文：

```text
使用 $xiaoyuzhou-to-article-qwen，把这个小宇宙单集转成文字稿和结构化播客笔记：
https://www.xiaoyuzhoufm.com/episode/...
```

### 第一次运行会发生什么

1. `podpull` 下载音频，并用 `ffprobe` 验证文件可以读取。
2. Agent 打开通义听悟，尝试上传音频。
3. 如果登录失效、出现验证码或文件选择器不可控，Agent 会显示音频路径，请用户接管。
4. 通义听悟完成转写后，优先导出 Markdown、TXT 或 DOCX。
5. Agent 检查文稿不是空文件，并确认节目开头、中段和结尾都存在。
6. Agent 根据固定结构生成 Markdown 笔记。

通义听悟网页状态不稳定时，上传和导出可能需要手动操作。音频下载、完整性检查和笔记整理仍由 skill 接着完成，不需要重新下载。

## 文字稿会整理成什么样

这个 skill 不做逐字润色，也不会把全文简单缩短。它的目标是让读者快速理解节目讲了什么、讲述顺序如何推进、哪些观点值得留下。

完整规则见 [`references/output-format.md`](xiaoyuzhou-to-article-qwen/references/output-format.md)。生成文件固定包含下面五部分。

### 1. 总的概括

- 用 300–500 字说明整期节目。
- 交代节目围绕什么问题展开。
- 提取核心观点和听完能获得的内容。
- 原文存在明显主线时，直接指出主线。
- 避免只写节目简介或空泛评价。

### 2. 按讲述顺序整理模块

模块必须按照播客原文的先后顺序排列，不按主题重新打散。每个模块都包含一张信息表和一段完整总结：

```markdown
### 模块一：模块标题

| 项目 | 内容 |
|---|---|
| 这一段主要在讲什么 |  |
| 核心观点 |  |
| 关键例子/故事 |  |
| 值得记住的点 |  |

主要内容：

用完整段落说明讲述者如何展开、前后逻辑是什么，以及这个部分为什么重要。
```

模块数量不预设，根据节目实际内容划分。赞助内容、正式正文和片尾如果性质不同，也会分开标注，避免和节目观点混在一起。

### 3. 金句摘录

- 从原文提取 8–15 条有价值的句子。
- 优先保留有洞察、有表达力或有启发的原话。
- 原句太口语化时只做轻微修整，不改变原意。
- 每条金句都补充“适合理解为”，说明它值得记住的原因。

输出格式：

```markdown
| 金句 | 适合理解为 |
|---|---|
| 原文或轻微修整后的句子 | 这句话表达的观点 |
```

### 4. 我的快速理解版

- 使用不超过 10 条 bullet points。
- 覆盖事件、论证或讨论中最关键的节点。
- 适合没有时间阅读完整笔记时快速浏览。
- 不重复堆叠同一个结论。

### 5. 可复制到 Obsidian 的笔记结论

最后生成一段可直接放进知识库的总结：

- 语言简洁，保留明确观点。
- 不使用空泛的 AI 套话。
- 不复述整篇笔记。
- 重点沉淀这期内容带来的判断、提醒或启发。

### 内容准确性约束

- 不补充原文没有的事实。
- 明显的转写错误可以根据上下文谨慎修正。
- 无法确认的内容标注“此处可能存在转写误差”。
- 说话人身份不明确时，不强行命名。
- 金句必须能在原文中找到对应表达。

最终文件名为：

```text
播客标题-内容整理.md
```

## 输出目录

默认保存到：

```text
~/Documents/podcast-notes
```

可通过环境变量修改：

```bash
export PODCAST_NOTES_DIR="$HOME/your-notes-folder"
```

如果同名文件已经存在，skill 会暂停并询问，不会直接覆盖。

## 更新

使用 `$skill-installer` 安装的用户，可以再次提交相同的 GitHub 子目录地址进行更新。

手动安装的用户可以拉取最新代码，再复制 skill 目录：

```bash
cd xiaoyuzhou-to-article-qwen
git pull
cp -R xiaoyuzhou-to-article-qwen/. \
  "${CODEX_HOME:-$HOME/.codex}/skills/xiaoyuzhou-to-article-qwen/"
```

更新后重新打开 Codex 会话。

## 已知限制

- 通义听悟需要用户自行登录。
- 网页自动操作失败、出现验证码或文件选择器不可控时，需要用户接管上传或导出。
- 通义听悟的页面、额度和服务规则变化后，工作流可能需要更新。
- 本项目不提供通义听悟 API，也不会创建或读取用户密码、验证码。
- Windows 和 Linux 尚未完成端到端验证。

## 隐私与版权

上传前请确认你有权处理该音频，并接受将音频发送给通义听悟进行转写。不要上传包含敏感个人信息、保密内容或无权处理的音频。

## 许可证

[MIT](LICENSE)
