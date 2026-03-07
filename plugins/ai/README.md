# AI Assistant Plugin for Lite-XL

A powerful AI-powered code assistant for the [Lite-XL](https://github.com/lite-xl/lite-xl) text editor. Supports multiple LLM providers (OpenAI, Ollama, Anthropic, and custom endpoints) with various AI capabilities.

## Features

- ✨ **Code Completion** - Autocomplete code with context-aware suggestions
- 💡 **Code Explanation** - Get detailed explanations of code snippets
- 🚀 **Code Generation** - Generate code from natural language descriptions
- ♻️ **Refactoring** - Automatically refactor code for better efficiency
- 🐛 **Bug Detection** - Analyze code for bugs and potential issues
- 🤖 **Custom Prompts** - Send any custom prompt to the AI

## Installation

1. **Copy the plugin file or directory** to your Lite-XL plugins directory:
   - Linux/MacOS: `~/.config/lite-xl/plugins/ai/`
   - Windows: `C:\Users\<username>\.config\lite-xl\plugins\ai\`

2. **Copy the entire `ai/` folder** if using external dependencies

3. **Or use the plugin manager**:
   ```bash
   lpm install ai
   ```

4. **Configure your API provider** (see [Configuration](#configuration) section below)

## Configuration

The plugin supports multiple AI providers. Configure it via Lite-XL settings:

### OpenAI

1. Get your API key from [platform.openai.com](https://platform.openai.com/api-keys)
2. In Lite-XL settings:
   - Set `API Provider` to "OpenAI"
   - Set `OpenAI API Key` (or use `OPENAI_API_KEY` environment variable)
   - Choose your model: `gpt-4`, `gpt-3.5-turbo`, etc.

**Environment Variable Alternative**:
```bash
export OPENAI_API_KEY="sk-..."
```

### Ollama (Local Models)

1. **Install Ollama** from [ollama.ai](https://ollama.ai)
2. **Start the Ollama server**:
   ```bash
   ollama serve
   ```
3. **Pull a model**:
   ```bash
   ollama pull llama2
   ollama pull mistral
   ollama pull neural-chat
   ```
4. In Lite-XL settings:
   - Set `API Provider` to "Ollama"
   - Set `Ollama Endpoint` to `http://localhost:11434/api/generate`
   - Set `Ollama Model` to your chosen model (e.g., `llama2`, `mistral`)

**Benefits**: Completely local, no API costs, works offline

### Anthropic

1. Get your API key from [console.anthropic.com](https://console.anthropic.com)
2. In Lite-XL settings:
   - Set `API Provider` to "Anthropic"
   - Set `Anthropic API Key` to your key
   - Model is automatically set to the latest (e.g., `claude-3-sonnet-20240229`)

### Custom Endpoint

For self-hosted models or other LLM services:

1. In Lite-XL settings:
   - Set `API Provider` to "Custom Endpoint"
   - Set `Custom Endpoint` to your API URL (must be OpenAI-compatible format)
   - Set `Custom Model` to your model name

**Example**: Using a self-hosted Ollama via custom endpoint:
```
Custom Endpoint: http://your-server:11434/api/generate
Custom Model: llama2
```

## Usage

### Keybindings

| Keybinding | Action |
|-----------|--------|
| `Ctrl+Shift+A` | Complete code |
| `Ctrl+Shift+E` | Explain code |
| `Ctrl+Shift+G` | Generate code from description |
| `Ctrl+Shift+R` | Refactor code |
| `Ctrl+Shift+B` | Find bugs |
| `Ctrl+Shift+P` | Custom prompt |

### Commands (via Command Palette)

Access via `Ctrl+Shift+P` > search for:
- `ai:complete` - AI Completion
- `ai:explain` - AI Explanation
- `ai:generate` - AI Code Generation
- `ai:refactor` - AI Refactoring
- `ai:find-bugs` - AI Bug Detection
- `ai:custom` - AI Custom Prompt

### Context Menu

Right-click in the editor to see:
- AI: Complete
- AI: Explain
- AI: Refactor
- AI: Find Bugs
- AI: Generate Code
- AI: Custom Prompt

## Settings

Configure in Lite-XL settings under "AI Assistant":

| Setting | Default | Description |
|---------|---------|-------------|
| Enable | `true` | Enable/disable the plugin |
| API Provider | `openai` | Choose: openai, ollama, anthropic, custom |
| Temperature | `0.7` | Randomness (0-2): lower = focused, higher = creative |
| Max Tokens | `2000` | Maximum response length |
| Timeout | `30` | Network timeout in seconds |

## Examples

### Code Completion
1. Start typing code or paste incomplete code
2. Press `Ctrl+Shift+A`
3. The AI will complete or extend your code

### Explanation
1. Select a code snippet
2. Press `Ctrl+Shift+E`
3. It will generate documentation as comments

### Code Generation
1. Press `Ctrl+Shift+G`
2. Describe what you want: "function to calculate factorial"
3. AI generates the code

### Refactoring
1. Select code to refactor
2. Press `Ctrl+Shift+R`
3. Optionally add goal: "make it more efficient"
4. Code is replaced with refactored version

### Bug Finding
1. Select code snippet
2. Press `Ctrl+Shift+B`
3. AI analyzes and suggests fixes

### Custom Prompt
1. Select text (or nothing for general prompt)
2. Press `Ctrl+Shift+P`
3. Enter your prompt
4. AI responds with the result

## Tips

1. **Better Results**: More context = better responses. Select the relevant code section.
2. **Temperature**: Lower for technical accuracy, higher for creative suggestions
3. **Cost Management** (OpenAI): Monitor token usage. Adjust `Max Tokens` if needed.
4. **Local Model**: Use Ollama for free, unlimited local processing
5. **API Keys**: Use environment variables instead of storing in config for security

## Troubleshooting

### "API key not configured"
- Set environment variable: `export OPENAI_API_KEY="your-key"`
- Or configure in plugin settings

### Network timeout errors
- Increase `Timeout` setting (default 30s)
- Check internet connection
- Verify API endpoint is accessible

### "Invalid response" errors
- Verify API endpoint is correct
- Check API service status
- Try with a different model

### Ollama not connecting
- Ensure Ollama is running: `ollama serve`
- Check endpoint: `http://localhost:11434`
- Try: `curl http://localhost:11434`

### Token limit exceeded
- Reduce `Max Tokens` setting
- Use smaller code selections
- Try a smaller model

## Performance Notes

- **OpenAI**: Fast, high quality, costs money per request
- **Ollama**: Local processing, slower but free, works offline
- **Anthropic**: Balanced speed/quality, costs money per request
- **Custom**: Depends on your setup

## Security

- API keys are stored in Lite-XL config (use environment variables instead)
- Requests are sent over HTTPS (when using OpenAI/Anthropic)
- Local Ollama requires no key, fully private

## Future Enhancements

- Streaming responses for faster feedback
- Code diff view for refactoring changes
- History/undo integration
- Syntax highlighting in responses
- Multiple file context
- Custom system prompts

## License

Same as Lite-XL plugins repository

## Support

For issues or feature requests, please visit the [lite-xl-plugins repository](https://github.com/adamharrison/lite-xl-plugins)
