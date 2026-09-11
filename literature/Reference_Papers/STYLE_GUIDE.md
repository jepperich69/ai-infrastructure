# Research Writing Style Guide

This guide codifies the shared writing style across the reference papers in this folder. When editing or drafting research text, emulate this style — not a generic AI style. The section "Natural academic writing" lists the AI tells to remove.

**Scope.** The guide applies to every edit of research text, not only to dedicated style passes. Any sentence or paragraph added, rewritten, or touched for any reason (a content change, a reviewer response, a corrected claim, a new result, a caption, an abstract) must obey it on the first write. A content edit that introduces a banned word, an em-dash connector, or a bold header is a defective edit, even when the content is correct.

## Reference papers (in this folder)

- **Einstein (1905)** — *On the Electrodynamics of Moving Bodies*
- **Akerlof (1970)** — *The Market for Lemons*
- **Kahneman & Tversky (1979)** — *Prospect Theory*
- **Ioannidis (2005)** — *Why Most Published Research Findings Are False*
- **Dantzig & Thapa** — *Linear Programming: Introduction*

---

## Core principles

**Economy.** Every word earns its place. Cut anything that does not add information or logical force.

**State the problem, then solve it.** The opening paragraph tells the reader exactly what the paper addresses and why it matters. No long wind-ups.

**Concrete before abstract.** Ground every abstract claim in a specific, simple example before generalizing. In Akerlof, the entire theory of adverse selection is built on a used car. In Einstein, the magnet-conductor asymmetry motivates special relativity. The example is not decoration — it is the argument.

**One logical load per sentence.** Sentences may be long (Einstein's are), but each carries one idea. Complexity lives in the logic, not in syntactic nesting or stacked subordinate clauses.

**Active voice, first person plural.** Write "We show," "We assume," "We define." Not "It is shown that," "It has been demonstrated that," "One can observe."

**Consistent terminology.** Once a term is defined, use it exactly. Do not substitute synonyms for variety. Kahneman & Tversky write "prospects" throughout — not "gambles," "lotteries," or "options" interchangeably.

**Transitions that advance the argument.** Transitions should carry logical force, not just signal continuation. Use "This implies," "The reason is," "As a result," "It follows that" — not "Furthermore," "Additionally," "Moreover," "In addition."

**No hedging filler.** Claim what you can defend, then defend it. Drop: "may potentially," "could possibly," "it might be suggested that," "somewhat," "rather," "one might argue."

**No meta-commentary.** Do not announce what you are about to do — just do it. Cut: "In this section we show that...," "We now turn to the question of...," "Before proceeding, it is useful to note that..."

---

## Banned phrases and substitutions

| Avoid | Replace with |
|-------|-------------|
| delve into | examine, study, analyze |
| showcase | show, demonstrate |
| leverage (verb) | use, exploit |
| robust (overused) | strong, stable — or drop |
| nuanced | (be specific instead; drop the word) |
| it is worth noting that | (just state it) |
| it is important to note that | (just state it) |
| needless to say | (if needless, omit) |
| in order to | to |
| due to the fact that | because |
| utilize / utilization | use |
| furthermore / moreover / additionally | (use logical connectors or none) |
| it can be seen that | (just state it) |
| paradigm | (usually unnecessary — be specific) |
| certainly / absolutely | (drop; assert the claim directly) |
| going forward | (drop or be specific) |
| in conclusion | (just conclude) |
| a number of | several, many, or give the number |
| significant (non-technical) | large, substantial, meaningful |
| facilitate | help, enable, allow |
| load-bearing (non-structural) | central, essential, decisive — or name what depends on it |
| aware (compound adjective: context-aware, uncertainty-aware) | "accounts for X", "conditions on X" — unless the compound is an established technical term |
| unpack | explain, decompose, examine |
| landscape / ecosystem / realm | (name the actual field, set, or system) |
| holistic | complete, joint, system-wide — or be specific |
| seamless | (drop; say what actually connects) |
| multifaceted | (list the facets or drop) |
| pivotal / crucial | (drop; if it matters, say why) |
| compelling | (drop; let the evidence carry it) |
| transformative | (drop; state the change) |
| navigate | handle, solve, address |
| underscore / highlight / illuminate | show, imply, indicate — or drop |
| foster / harness / unlock | enable, use, obtain |
| interplay | interaction, dependence (name the mechanism) |
| at its core | (drop) |
| importantly / notably | (drop; the sentence should carry its own weight) |
| in today's rapidly evolving ... | (drop) |
| sheds light on / offers a lens | shows, explains, measures |
| raises important questions | (state the question) |
| serves as a | is |
| represents a significant | is a |
| not only ... but also | and — or two sentences |
| rather than simply / more than just | (drop; state the claim) |
| This highlights / underscores ... | This implies, This shows — or drop |
| provides an X-aware framework | accounts for X |

---

## Structural patterns to avoid

- **Bullet lists where prose would be tighter.** These papers rarely use bullets in the body. Claims follow from one another in connected prose.
- **Summaries that restate what was just said.** If the argument was clear, no summary is needed. If it was not clear, fix the argument.
- **Qualifications piled on qualifications.** "While it may be the case that, in some contexts, certain aspects could potentially..." — state the condition once, precisely.
- **Adjective inflation.** "Highly significant," "very important," "extremely relevant" — the adjective adds nothing. Either the thing is significant or it is not.
- **Section-opening announcements.** Do not open a section with a sentence that describes the section. Open with the first substantive claim.

---

## Natural academic writing (anti-LLM pass)

Write like an experienced researcher, not like an AI assistant. The reference papers read as the work of a person with something specific to say. Generic AI prose reads as promotion: it announces importance instead of demonstrating it.

**Prefer concrete nouns and verbs.** "The model accounts for X" beats "The model provides an X-aware framework." State what the model, result, or mechanism does. Rhetorical inflation ("pivotal," "transformative," "compelling") is a claim without evidence; delete it and let the result carry the weight.

**Delete words that do not change the technical meaning.** If removing a word leaves the claim unchanged, the word was decoration.

**Reserve technical words for their technical meaning.** "Robust" means something in statistics and optimization; do not use it as praise. "Aware" as a compound adjective (context-aware, uncertainty-aware) is fashionable, not informative, unless the compound is an established term in the field.

**Avoid the recognizable LLM rhythms:**
- Em-dashes as clause connectors (see below)
- Three-item rhetorical lists assembled for cadence rather than content
- "Not only ... but also," "rather than simply," "more than just"
- Sentences opening with "This highlights/underscores ..."
- Bold paragraph headers (`\textbf{}`) in manuscripts: use `\textit{}`

**Em-dashes.** Use a comma, colon, or two sentences instead of an em-dash that joins two clauses. Keep em-dashes only for a true parenthetical enclosed on both sides. In `.tex` source, prefer ASCII (`--`, `---`) over Unicode dashes; Unicode dashes corrupt latexdiff output (known issue #13).

**Preserve technical terminology, equations, and claims.** The pass is stylistic: no claim gets weakened, strengthened, or re-scoped, and no equation or defined term is touched.

**Do not simplify into plainness.** The target is precise, compact prose fit for a strong journal, not a popular summary. Long sentences are fine when each carries one logical load.

**Final pass.** After editing, reread every sentence and flag any that still sounds generic, promotional, or recognizably LLM-written. Rewrite it more directly, usually by naming the concrete subject and the concrete verb.

## Tone

These papers are confident without being arrogant. They do not hedge their claims unnecessarily, but they are also careful about what they claim. Einstein says "We will raise this conjecture to the status of a postulate" — a precise, confident statement of scope. Akerlof says "This paper relates quality and uncertainty" — direct, no inflation. Kahneman & Tversky say "This paper presents a critique of expected utility theory" — they state the adversarial claim plainly on line one.

Write at that register: confident, precise, unpretentious.
