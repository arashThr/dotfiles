# Step 05 — Ollama client + prompt scaffolding

## Read first
- `brain-plan/00-overview.md` (Tech stack — fixed)
- `brain-plan/PROGRESS.md`
- Ollama API docs (chat, embed): https://github.com/ollama/ollama/blob/main/docs/api.md

## Goal
A reusable Ollama client and a prompt-template loader.

## Tasks

1. New package `internal/llm/`:
   ```go
   type Client struct { /* host, http.Client, timeouts */ }

   func New(cfg config.Ollama) *Client

   // Chat: non-streaming for simplicity in v1.
   func (c *Client) Chat(ctx context.Context, model string, msgs []Message, opts ...Option) (string, error)

   // Embed a batch of texts.
   func (c *Client) Embed(ctx context.Context, model string, texts []string) ([][]float32, error)

   // JSON mode: passes Ollama's `format: "json"` and validates result parses as JSON.
   func (c *Client) ChatJSON(ctx context.Context, model string, msgs []Message, out any) error
   ```
2. Options: temperature, num_ctx, seed (deterministic for tests).
3. Retry: 3 attempts with exponential backoff on 5xx and connection errors. Don't retry on 4xx.
4. Logging: structured (slog), at debug level log full request/response (gated behind `BRAIN_DEBUG=1`).
5. New package `internal/prompts/`:
   - `//go:embed templates/*.tmpl`
   - `Render(name string, data any) (string, error)` using `text/template`.
   - On first run, copy embedded templates to `~/notes/.brain/prompts/` if missing. Loader prefers user copy if present.
6. Add one starter template `templates/ping.tmpl`:
   ```
   Reply with exactly: "pong from {{.Model}}"
   ```
7. New subcommand `brain ping`:
   - Renders `ping.tmpl` with current curator model.
   - Calls `Chat`.
   - Prints response.
   - Exits non-zero if response doesn't contain "pong".

## Verify

```sh
brain ping                  # prints something containing "pong"
BRAIN_DEBUG=1 brain ping    # shows request/response in stderr
ls ~/notes/.brain/prompts/  # ping.tmpl present
# user override:
echo 'Say "hello override"' > ~/notes/.brain/prompts/ping.tmpl
brain ping                  # uses override
```

Tests:
- `prompts_test.go`: render with embedded; user override precedence.
- `llm_test.go`: hit `httptest.Server` mocking Ollama; assert retry behavior.

## Out of scope
- Streaming responses.
- Function calling / tools.
- Any business prompts (digest etc.).

## Commit
`feat: ollama client and prompt template loader`
