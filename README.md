# xiaoyuzhou-to-article-qwen

把小宇宙单集链接整理成完整文字稿和结构化 Markdown 笔记：

1. 使用 [podpull](https://github.com/xiaoleiy/podpull) 下载音频。
2. 使用用户已登录的通义听悟完成转写。
3. 检查导出文稿是否覆盖节目开头、中段和结尾。
4. 按固定模板生成概括、顺序模块、金句和快速理解版。

这是社区项目，不是阿里云、通义听悟或 Qwen 官方项目。名称中的 `qwen` 表示面向通义/Qwen 使用场景；音频转写由通义听悟完成，最终整理也可以由当前运行 skill 的其他模型执行。

## 前置条件

- Codex 或兼容 `SKILL.md` 的 Agent 环境
- [podpull](https://github.com/xiaoleiy/podpull)
- `ffprobe`（随 FFmpeg 提供）
- Chrome
- 可正常使用的通义听悟账号

macOS 可用 Homebrew 安装依赖：

```bash
brew install xiaoleiy/tap/podpull
brew install ffmpeg
```

其他系统请参考 podpull 和 FFmpeg 的上游安装文档。本项目当前已在 Apple Silicon macOS 上完成真实小宇宙单集验证。

## 安装

```bash
git clone https://github.com/yxqhuqin222-star/xiaoyuzhou-to-article-qwen.git
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
cp -R xiaoyuzhou-to-article-qwen/xiaoyuzhou-to-article-qwen \
  "${CODEX_HOME:-$HOME/.codex}/skills/"
```

重新打开 Codex 会话，然后直接发送小宇宙单集链接，或显式调用：

```text
Use $xiaoyuzhou-to-article-qwen to process:
https://www.xiaoyuzhoufm.com/episode/...
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

## 已知限制

- 通义听悟需要用户自行登录。
- 网页自动操作失败、出现验证码或文件选择器不可控时，需要用户接管上传或导出。
- 通义听悟的页面、额度和服务规则变化后，工作流可能需要更新。
- Windows 和 Linux 尚未完成端到端验证。

## 隐私与版权

上传前请确认你有权处理该音频，并接受将音频发送给通义听悟进行转写。不要上传包含敏感个人信息、保密内容或无权处理的音频。

## 许可证

[MIT](LICENSE)
