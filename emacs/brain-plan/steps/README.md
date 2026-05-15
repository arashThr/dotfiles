# Steps

Execute one per session. Each is self-contained but reads context from
[../00-overview.md](../00-overview.md) and [../AGENTS.md](../AGENTS.md).

| # | Step | Verifiable outcome |
|---|---|---|
| 01 | [Repo scaffold + Go module + notes dir](01-scaffold.prompt.md) | `brain doctor` exits 0 |
| 02 | [Daily-note open + carry-over](02-today-and-carryover.prompt.md) | `brain today` opens correct file; todos copied |
| 03 | [Tag parser + journal model](03-tag-parser.prompt.md) | `brain parse <file> --json` shows correct items |
| 04 | [Emacs plugin (brain.el)](04-emacs-plugin.prompt.md) | `M-x brain-today` works |
| 05 | [Ollama client + prompt scaffolding](05-ollama-client.prompt.md) | `brain ping` returns model output |
| 06 | [sqlite-vec index + embeddings](06-index.prompt.md) | `brain index` populates DB; `brain index --stats` shows counts |
| 07 | [Digest pipeline (dry-run)](07-digest-dryrun.prompt.md) | `brain digest --dry-run` prints planned patches |
| 08 | [Digest applies to staging branch](08-digest-apply.prompt.md) | `magit` shows diff on `brain/digest-*` branch |
| 09 | [RAG `ask` command](09-ask.prompt.md) | `brain ask "..."` returns cited answer |
| 10 | [Auto page-split](10-page-split.prompt.md) | Forced large page splits per heuristic |
| 11 | [Polish: doctor, config, error UX](11-polish.prompt.md) | All commands have `--help`, sensible errors |

After step 11 you have the v1 system. Web view and promo reports are
explicitly out of scope (see overview).
