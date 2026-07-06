---
name: xiaoyuzhou-to-article-qwen
description: |
  把小宇宙单集链接转成完整文字稿和结构化播客笔记。使用 podpull 下载音频，通过用户已登录的通义听悟完成转写并导出原始文稿，再整理为 Markdown；不依赖 Groq API。用户直接发送 xiaoyuzhoufm.com/episode/ 链接，或提出“小宇宙转文字”“播客文稿”“播客总结”“播客分章节”时使用。
---

# 小宇宙播客整理 Qwen 版

先把小宇宙单集链接转成完整原始文稿，再按 [播客笔记格式](references/output-format.md) 生成结构化 Markdown。

本 skill 是社区项目，不是阿里云、通义听悟或 Qwen 官方项目。通义听悟负责转写；内容整理使用当前运行本 skill 的模型，不强制限定模型供应商。

## 前置条件

- 本机已安装 `podpull`、`ffprobe`
- 浏览器可以访问通义听悟
- 用户已登录通义听悟；如果登录失效，让用户接管登录，不读取或代填密码、验证码
- 用户有权处理音频，并确认可以把音频上传到通义听悟

## 工作流程

### 1. 下载并验证音频

运行：

```bash
bash "${CODEX_HOME:-$HOME/.codex}/skills/xiaoyuzhou-to-article-qwen/scripts/prepare_audio.sh" \
  "<小宇宙单集链接>"
```

读取脚本输出的 `AUDIO_PATH`。不要仅凭下载命令成功判断音频可用；脚本已用 `ffprobe` 验证音频。

### 2. 上传到通义听悟

使用 Chrome 浏览器控制能力打开 `https://tingwu.aliyun.com/home`：

- 已登录：选择“上传音视频”或当前页面同义入口，上传 `AUDIO_PATH`。
- 未登录或出现验证码：停在当前页面，让用户完成登录或验证码后继续。
- 文件选择器无法自动处理：展示 `AUDIO_PATH`，让用户手动选择文件。macOS 可按 `Command + Shift + G` 后粘贴路径。
- 上传前确认是本次下载的播客音频，不上传无关文件。

选择中文或自动识别，提交转写任务。等待任务显示完成；不要高频轮询。

### 3. 导出转写结果

优先导出 Markdown、TXT 或 DOCX。若网页只支持复制全文，则复制到本地 Markdown 文件。保留原始导出文件，不覆盖。

检查导出文件不是空文件，且包含节目开头、中段和结尾的内容。

### 4. 生成播客笔记

完整读取 [播客笔记格式](references/output-format.md)，严格按其中结构整理，不擅自增删栏目。

输出目录：

```text
${PODCAST_NOTES_DIR:-$HOME/Documents/podcast-notes}
```

文件名使用 `播客标题-内容整理.md`。写入前检查同名文件是否已经存在；存在时暂停并询问用户，不直接覆盖。

## 失败处理

- `podpull` 失败：检查是否为 `/episode/` 单集链接，不回退到页面正则抓取。
- 通义听悟页面或上传失败：保留已下载音频并让用户接管，不重复下载。
- 通义听悟额度不足或开始收费：说明实际费用并暂停，不自动开通付费服务。
- 不使用 Groq，也不要求 `GROQ_API_KEY`。
