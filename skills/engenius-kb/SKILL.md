---
name: engenius-kb
description: >
  Answer questions about EnGenius products using the official Product SpecHub
  knowledge base (RAG Search API). Use this skill whenever the user asks about
  EnGenius products, specs, features, configuration, compatibility, deployment,
  or WiFi regulations — especially when they mention a model number (ECW…, ECS…,
  ESG…, ECC…, EVS…, EAP…, EOC…, ECP…) or say things like "哪些 AP 支援…",
  "…的規格", "怎麼設定…", "ECW536 和 ECC500 差在哪", "推薦…的網路方案",
  "EnGenius …", "查一下 SpecHub", "問 EnGenie", or invoke "/engenius-kb <question>".
  Trigger it whenever an answer should be grounded in EnGenius's own
  documentation rather than the model's general knowledge.
---

# EnGenius Knowledge (RAG Search API)

Ground answers in EnGenius Product SpecHub by retrieving the most relevant
knowledge-base chunks via the Search API, then answering **only** from what's
retrieved. We retrieve; you (Claude) generate.

## Setup (one-time, on this machine)

Two environment variables — the key is secret, never write it into a file or commit it:

```bash
export SPECHUB_API_KEY="sk_live_xxx"                       # mint at EnGenie → Settings → API Access
export SPECHUB_API_BASE="https://engenie-eg.vercel.app"   # optional; this is the default
```

If `SPECHUB_API_KEY` is unset, stop and tell the user to export it (and where to
get one: EnGenie → Settings → API Access). Do not proceed without it.

## How to answer

1. **Form the query.** Use the user's question (the `/engenius` argument, or the
   current question in context) as the `query`. Keep it to the actual question —
   don't paste whole conversations (max 2000 chars).

2. **Call the Search API** with the Bash tool. Build the JSON safely with `jq`
   (handles quotes / CJK); if `jq` is missing, use the `python3` form below.

   ```bash
   BASE="${SPECHUB_API_BASE:-https://engenie-eg.vercel.app}"
   curl -s -X POST "$BASE/api/v1/search" \
     -H "Authorization: Bearer $SPECHUB_API_KEY" \
     -H "Content-Type: application/json" \
     --data "$(jq -n --arg q "USER_QUESTION_HERE" '{query:$q, top_k:8}')"
   ```

   python3 fallback for the `--data` value:
   ```bash
   --data "$(python3 -c 'import json,sys; print(json.dumps({"query": sys.argv[1], "top_k": 8}))' "USER_QUESTION_HERE")"
   ```

   To narrow the search, add fields to the JSON (only within your key's scope):
   - `"source_types": ["product_spec","helpcenter"]`
   - `"taxonomy": {"product_lines": ["Cloud AP"]}`
   - `"top_k": 12` (1–20) for broader questions.

3. **Read the JSON response.**
   - Success: `{ "ok": true, "count": N, "results": [ { content, title, source_type, source_id, source_url, score, taxonomy } ] }`.
   - Failure: `{ "ok": false, "error": "…" }` — handle per the table below.

4. **Answer from the results ONLY.**
   - Base the answer strictly on `results[].content`. Do **not** add product
     facts from general/training knowledge — if the chunks don't cover it, say
     so plainly and suggest rephrasing or naming a specific model.
   - Lead with the direct answer; use a Markdown table when comparing 2+ models.
   - **Bold** model numbers and key spec values.
   - Cite sources: reference `title` and, when `source_url` is present, link it.
   - Answer in the **same language** the user asked in.
   - Ignore low-signal hits (e.g. `score` < ~0.3) if better ones exist.

5. **If `count` is 0**, tell the user no relevant content was found and suggest a
   more specific query (e.g. a model number) — don't fabricate an answer.

## Error handling

| HTTP / error | Meaning | What to do |
|---|---|---|
| `401` Invalid/Missing key | key wrong or `SPECHUB_API_KEY` unset | Ask the user to set / re-check the key |
| `403` API key disabled | key disabled in admin | Tell the user to contact the EnGenie admin |
| `429` Rate limit exceeded | per-minute cap hit | Wait a few seconds and retry once |
| `400` | bad request (e.g. empty/too-long query) | Shorten / fix the query |
| `500` | server error | Retry once; if it persists, report it |

## Notes

- **Server-to-server**: this runs from your machine with your key; never expose
  the key in any committed file or shared output.
- The knowledge base auto-updates (daily/weekly), so results are always current.
- This skill only **retrieves**. The synthesis, formatting, and citations are
  your job as the answering model.
