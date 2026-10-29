---
name: interview-notes
description: Manages company interview notes in Ravil's Obsidian vault at 01-Work/reference/companies/. Use this skill when the user shares a job posting, recruiter message, company info to log, interview Q&A to record, or a hiring outcome (offer/rejection) for a specific company. Triggers include phrases like "add this company", "log this interview", "ingest position at X", "create a note for company Y", "feedback from [company name]", or when the user pastes a job description, recruiter outreach, or rejection email.
---

# Interview Notes

Manages single-file company interview notes in Ravil's Obsidian vault. One file per company at `01-Work/reference/companies/{Company}.md`. Each note evolves through three phases: ingest → interview → outcome.

## When to use

Trigger when the user:
- Pastes a job description, recruiter outreach, or company info and wants it logged
- Says "add/log/ingest" a company or position
- Shares interview Q&A to record
- Shares a rejection email, offer, or hiring outcome
- Asks to update an existing company note with new stage results

Do NOT trigger for the heavy multi-file format under `01-Work/projects/{company}-application/` (used for full application tracking with stage-by-stage subfiles). The single-file companies format is the default; only use the application folder if the user explicitly asks for it or one already exists for that company.

**Check the promoted and archived locations too** before assuming a company is new — a note may have moved without being renamed:

| Stage | Location |
|---|---|
| Inbound / applied / recruiter screen | `01-Work/reference/companies/{Company}.md` |
| Multi-round process in flight | `01-Work/projects/{company}-application/{Company}.md` |
| Closed (rejected / declined / pulled) | `01-Work/_archive/companies/{Company}.md` |

When a process goes multi-round (HM + technical + final, or a take-home lands), promote: create the application folder and `git mv` the note in **unrenamed**, so `[[Company]]` wikilinks keep resolving. When it closes, fill in `## Outcome` first, then move to `_archive/companies/`. Full rule: `01-Work/reference/companies/_README.md`.

## File location and naming

- Path: `/Users/ravil/Documents/obsidian/01-Work/reference/companies/{Company}.md`
- Filename: company name in PascalCase, no suffix (e.g. `Qonto.md`, `McMakler.md`, not `Qonto-Application.md`)
- Template source: `/Users/ravil/Documents/obsidian/Templates/Interview.md`

## Template structure

The note has six sections in this fixed order:

1. **Position** — role, location, stack, comp band, job posting URL
2. **Company** — what they do, team/org, why interesting
3. **Process** — checklist of interview stages
4. **Questions to ask** — split into two groups:
   - **Show homework / interest:** company-specific questions that prove research
   - **For my own information:** practical questions (comp, hybrid policy, next steps, timeline)
5. **Q&A** — repeating `### Q:` / `A:` blocks for questions THEY asked
6. **Notes** — freeform: culture links, prep reminders, lessons from prior interviews

Frontmatter:
```yaml
---
creation date: DD.MM.YYYY
modification date: <weekday + date>
tags:
  - interview
  - career
status: active   # active | rejected | offer | withdrawn | on-hold
---
```

See `references/template.md` for the canonical empty template.

## Workflow

### Phase 1 — Ingest (new company)

When the user shares a job posting + recruiter message:

1. Create `01-Work/reference/companies/{Company}.md` from the template
2. Fill **Position** from the job description (role, location, stack, comp if stated, job URL)
3. Fill **Company** from research/description (what they do, team size and structure, founding details, scale metrics, why interesting — focus on facts that aid interview prep)
4. Leave **Process** checklist unchecked, with stage names
5. Seed **Questions to ask** based on what the posting reveals or hides:
   - If comp band is missing → add comp question
   - If team/domain is vague → add team question
   - If role title is ambiguous (e.g. "Senior/Staff") → add IC ladder question
   - If location says "remote-friendly" → add office presence question
   - Always include: "Who thrives here, and who doesn't?" and a timeline/next-steps question
6. In **Notes**, add culture/blog links worth reading, prep reminders, and carry forward any lessons from prior rejections (read recent `Outcome` sections in other Companies/ notes for patterns)

### Phase 2 — Interview rounds

When the user shares Q&A or notes from a call:

1. Check off the relevant stage in **Process**
2. For questions THEY asked the user → add `### Q: <question>` / `A: <answer summary>` blocks under **Q&A**
3. For new info learned (comp ranges, team details, timeline) → update **Position**/**Company** in place, don't duplicate
4. New questions to ask next round → append to **Questions to ask**
5. Freeform observations → **Notes**

### Phase 3 — Outcome

When the user shares a rejection, offer, or withdrawal:

1. Flip frontmatter `status:` to `rejected` / `offer` / `withdrawn` / `on-hold`
2. Add an **Outcome** section at the bottom of the note with:
   - Date and source (e.g. "Rejected — 2026-06-01, from Candice (recruiter)")
   - **Reasons given** — numbered list, paraphrased honestly
   - **Positives called out** — what they liked
   - **Takeaways** — what to apply next time (lead with X stories, comp data point, etc.)
3. Mark the relevant stage in **Process** as the last one completed and note `**Outcome:**` pointer near the top of Process

## Operating principles

- **Don't overcomplicate.** Single file per company. No subfolders, no extra metadata, no overengineering. If the user wants the heavy format they will ask explicitly.
- **Edit in place.** When new info arrives for an existing company, update the existing note. Don't create dated variants.
- **Cross-link rejections.** When seeding Notes for a new company, scan the **Outcome** sections in `01-Work/_archive/companies/` (that's where closed processes land) and carry forward applicable takeaways with a `[[CompanyName]]` link.
- **Keep questions actionable.** Phrase questions the way the user would speak them, not formal. Short is better. ("Who thrives here, and who doesn't?" beats "What separates people who thrive here from those who don't quite stick?")
- **Respect existing edits.** The user actively edits these notes mid-process (inline answers under bullets, sub-bullets for follow-up). Preserve their additions; insert new content rather than overwriting.
- **Dates use vault convention.** `creation date: DD.MM.YYYY`, modification date is human-readable (`1st June 2026`). Use the current date from system context, not guesses.

## Related files

- Vault root CLAUDE.md: `/Users/ravil/Documents/obsidian/CLAUDE.md` (vault conventions, PARA, frontmatter)
- Template: `/Users/ravil/Documents/obsidian/Templates/Interview.md`
- Stage/promotion rule: `/Users/ravil/Documents/obsidian/01-Work/reference/companies/_README.md`
- Existing examples to mirror: `01-Work/_archive/companies/Qonto.md` (full lifecycle including Outcome), `01-Work/_archive/companies/McMakler.md` (declined on comp), `01-Work/_archive/companies/Intercom.md` (early-stage), `01-Work/projects/nebius-application/Nebius.md` (promoted, multi-round)
