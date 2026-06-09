# claude-skills

Shareable [Claude Code](https://claude.com/claude-code) skills for the EnGenius team.
Drop-in skills that any teammate can install with one command. **No secrets live
in this repo** — skills read API keys from your environment.

> 中文逐步安裝說明 → [安裝說明.md](安裝說明.md)

## Install (all skills)

```bash
curl -fsSL https://raw.githubusercontent.com/terrelyeh/claude-skills/main/install.sh | bash
```

This copies everything under [`skills/`](skills/) into `~/.claude/skills/`.
Re-run any time to update. Then restart Claude Code.

## Skills

### `engenius-kb` — EnGenius Knowledge (RAG Search)
Gives Claude Code access to the EnGenius Product SpecHub knowledge base (product
specs, GitBook, Help Center, Google Docs, WiFi regulations, web pages). Ask a
product question and it retrieves the most relevant content via the Search API,
then answers with sources.

**Setup (one time):**
```bash
echo 'export SPECHUB_API_KEY="sk_live_xxx"' >> ~/.zshrc   # key from your admin
source ~/.zshrc
```
Optional: `export SPECHUB_API_BASE="https://ds-generator-eg.vercel.app"` (default).

**Use:** `/engenius-kb 哪些 AP 支援 WiFi 7?` — or just ask EnGenius product
questions and it triggers automatically.

API reference: https://ds-generator-eg.vercel.app/docs/api-search.html

## Adding a new shareable skill

1. Create `skills/<your-skill>/SKILL.md` (YAML frontmatter `name` + `description`, then instructions).
2. Keep secrets OUT — read them from env vars, never hardcode.
3. Commit & push. Teammates re-run the install command to get it.

## Key management (admins)

Mint per-person / per-team API keys at **SpecHub → Settings → API Access
(Departments)**. Each key is scoped + rate-limited and can be revoked
individually. Keys are stored hashed (verification) + AES-encrypted (re-copy),
never in this repo.
