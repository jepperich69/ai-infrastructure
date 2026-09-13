# Research Writing Style Guide

This guide defines how research text is written and edited. The target is not a generic academic style and not the compressed style of the classic reference papers alone. It is the voice of the author's own published papers (listed below), with the AI tells removed. When the two conflict, the author's own papers win.

**Scope.** The guide applies to every edit of research text, not only to dedicated style passes. Any sentence or paragraph added, rewritten, or touched for any reason (a content change, a reviewer response, a corrected claim, a new result, a caption, an abstract) must obey it on the first write. A content edit that introduces a banned word, an em-dash connector, or a bold header is a defective edit, even when the content is correct.

**Calibration date.** Revised 2026-09-13 from a grilling session in which the author chose between candidate sentences. The picks are recorded in the section "Decision record" at the end.

## Reference papers (in this folder)

Author's own papers (primary calibration for voice, vocabulary, and sentence shape):

- **Paulsen & Rich (2023)** Societally optimal expansion of bicycle networks, *Transportation Research Part B* (`1-s2.0-S0191261523000954-main.pdf`)
- **Hipolito, Vandet & Rich (2022)** Charging, steady-state SoC and energy storage distributions for EV fleets, *Applied Energy* (`1-s2.0-S0306261922004597-main.pdf`)
- **Borysov, Rich & Pereira (2019)** How to generate micro-agents? A deep generative modeling approach to population synthesis, *Transportation Research Part C* (`1-s2.0-S0968090X1831180X-main.pdf`)
- **Rich (2020)** A spline function class suitable for demand models, *Econometrics and Statistics* (`1-s2.0-S2452306218300078-main.pdf`)
- **Rich (2024)** Let's walk! The fallacy of urban first- and last-mile public transport, *Transportation* (`s11116-024-10505-5-1.pdf`)

Classic papers (secondary: register, confidence, and the concrete-example habit):

- **Einstein (1905)** On the Electrodynamics of Moving Bodies
- **Akerlof (1970)** The Market for Lemons
- **Kahneman & Tversky (1979)** Prospect Theory
- **Ioannidis (2005)** Why Most Published Research Findings Are False
- **Dantzig & Thapa** Linear Programming: Introduction

---

## Core principles

**Explain, do not compress.** This is the first rule and it overrides the old "economy" rule. When a claim has a reason, state the reason in full, in its own clause or its own sentence, even when a reader could infer it. Two clear sentences beat one packed sentence. Compression by colon, by em-dash, or by stacking clauses is the main source of text that reads as AI-written and hard to follow.

Preferred:
> For this reason, conventional bottom-up cost-benefit analysis cannot be applied. Even a small set of possible solutions would be computationally infeasible to evaluate, because each evaluation requires a full traffic assignment.

Not preferred:
> Bottom-up cost-benefit analysis fails here: evaluating even a small set of expansion plans is computationally infeasible.

**Economy still applies to decoration, not to reasoning.** Delete words that carry no information (intensifiers, promotional adjectives, "it is worth noting that"). Do not delete words that carry the argument, the qualification, or the mechanism.

**One subordinate clause per sentence.** A sentence may carry one condition or contrast in a subordinate clause ("Although ..., ...", "..., which ...", "..., as ..."). When a second clause would be chained on, start a new sentence. There is no word-count limit; the flag is structural: two or more chained subordinate clauses in one sentence.

Preferred:
> Although traditional transport model projections are useful when extending bicycle networks, they cannot determine when and where to invest.

Split when chained:
> The problem is complex and has been visited in the literature by e.g. Mesbah et al. (2012) and Liu et al. (2019). The complexity arises from dependencies between network segments, i.e. the fact that early expansions are taken into use before the entire expansion is complete.

**Reasons in separate sentences, not in colon lists.**
> The problem is challenging for two reasons. The first is that travel time benefits are non-linear. The second is that the planning horizon multiplies the combinatorial size of the network.

Colons are reserved for introducing an equation, a definition, or a displayed list.

**Paragraphs carry a complete line of argument.** A body paragraph runs 6 to 10 sentences and moves from a claim through its reasons to a qualification before the break. Short paragraphs of 3 to 4 sentences with one point each are an AI tell in a journal manuscript.

**State the problem, then solve it.** The introduction opens with one sentence of context, with citations, and the second sentence states what the paper does ("In this paper, we ..."). Do not run a paragraph of background before the paper appears.

**Concrete before abstract, in the right order.** The default order is the general claim followed by the example ("As an example, doubling the money spent on a bottle of wine does not double the pleasure it gives"). The example-first order (Akerlof's used car) is allowed in an opening paragraph. Examples are kept in the text, never moved to a footnote or dropped.

**Active voice, first person plural, as the default.** "We show," "We assume," "We define." The passive is not a defect when the agent is obvious or when "we" would be awkward in a single-author paper ("A function class is presented"). Do not rewrite every passive.

**Name the subject when drawing a consequence.** "This finding implies that ...", "This result suggests ...", "The model accounts for ...". Avoid the bare "This implies ..." and "This shows ..." openers, which AI prose overuses. "It follows that" is for the sentence after a proof. "Therefore" is fine in ordinary argument.

**Own contribution first, then the contrast.** State what the paper does in its own sentence, then contrast it with named papers: "This is in contrast with the models in Smith et al. (2019) and Jones (2020), which require population-specific calibration." Do not open with "While prior work has ..." or "Unlike existing methods, ...".

**Hedge once, with scope.** State the finding plainly, then name the scope of the evidence in a following clause: "First-mile services have minimal welfare impact for average trip distances below 1 km, and this conclusion appears robust even under conservative assumptions." Never stack hedges ("may ... could depend"). Never overclaim ("have no welfare impact").

**Qualifiers stay when they change the claim.** "Largely similar" is not "similar"; "reasonably sizable" is not "sizable". Keep "largely", "reasonably", "rather", "quite", "essentially" when removing them changes what is claimed. Replace the qualifier with a number whenever a number exists ("within 5% of").

**Consistent terminology.** Once a term is defined, use it exactly. Do not substitute synonyms for variety.

**Verbs, not nominalizations, for what we do.** Keep technical noun phrases intact ("stage-based cost-benefit optimization model") but put the action in a verb: "Second, we formulate a stage-based cost-benefit optimization model for expanding transport networks, which uses the link-based benefit measures." Not "The second contribution lies in the formulation of ...".

**Meta-commentary is allowed where the journal expects it.** "In this paper, we ...", the roadmap paragraph at the end of the introduction ("The paper is organized as follows"), and section openers ("In this section, we present ...") are all permitted. What is banned is the announcement that replaces content ("We now turn to", "Before proceeding, it is useful to note that").

**Enumerate in full sentences.** "Firstly, we propose ... Secondly, we formulate ... Thirdly, we apply ..." with each item as its own sentence. Inline "(i) ... (ii) ... (iii)" is fine for short parallel items, as in abstracts and definitions. The AI tell is not enumeration; it is a triplet assembled for rhythm with no content.

---

## Structure

- **Sections.** A paper has 5 to 6 top-level sections, each with at most 2 to 3 subsections. No sub-subsections. Do not fragment the paper into many short sections.
- **Section titles.** Short noun phrases ("Methodology", "Results"). No colons or questions in section titles; the paper title may have either.
- **Paragraph headers in body text.** `\textit{}`, never `\textbf{}`.
- **Bullet lists.** Not in body prose. Allowed for definitions with numbered properties, as in "Definition 1 ... (i) ... (ii) ... (iii)".
- **Abstract.** Narrative, 150 to 250 words: the problem, why it is hard, what we do, what we find, what it implies. The main quantitative result appears with its number ("a benefit-cost ratio of 2.7", "ten times larger"). The five-slot template (context, gap, method, result, implication; under 150 words) is used only when the venue asks for it.
- **Introduction.** Sentence one: context with citations. Sentence two: "In this paper, we ...". Contributions as "Firstly / Secondly / Thirdly", one sentence each. Roadmap paragraph at the end.
- **Intuition paragraph after every proof.** Two parts: one sentence on what the result buys us in the paper, one sentence on the mechanism behind it. Written in simple everyday wording, deliberately less formal than the proof, with no symbols where a word will do. This is the one place where the register drops on purpose.
- **Prose around equations.** The sentence before names every new symbol. The sentence after says what the equation does, in words.
- **Figure captions.** One sentence saying what is shown, then one sentence saying what to look for. No "This figure illustrates".
- **Table captions.** What is shown, units, and data source. No interpretation.
- **Footnotes.** For code availability and data notes only, not for argument.
- **Reviewer responses.** One thanks per reviewer at the top. Each point is answered with "We agree ..." or "We disagree because ...", followed by the exact change with section and page. No per-comment "insightful" or "valuable".

---

## Mechanics

- **Equation references.** Always `Eq. (x)`.
- **Citations.** Harvard: `Rich (2025)` narrative, `(Rich, 2025)` parenthetical. "e.g." inside the parenthesis is fine: `(e.g. Leleur, 2000)`.
- **Em-dash.** Never as a clause connector. Use a comma, a colon (equations, definitions, lists only), or two sentences. Keep an em-dash only for a true parenthetical enclosed on both sides. In `.tex` source prefer ASCII (`--` for ranges, `---` for the rare parenthetical); Unicode dashes corrupt latexdiff output (known issue #13).
- **Semicolon.** Only to separate list items that contain commas. Not to join two clauses.
- **Contractions.** None.
- **Numbers.** Digits for all quantities with units and for anything above nine. Words for one to nine when counting things ("three contributions").
- **Spelling.** Follow the journal: US for Elsevier (TR-B, TR-C, Econometrics and Statistics, Applied Energy), UK for Springer (Transportation). Enforce consistency within a manuscript.
- **Danish-English corrections.** Rewrite "at the offset" (at the outset), "in the paper" (in this paper), "concerning" (about, regarding), "with reference to" (see, following). These are copy-editor errors, not voice.

---

## Vocabulary

The style pass draws replacements from the permitted list below, which is taken from the author's own papers. A rewritten sentence must not introduce a non-technical word that is absent from those papers. The banned list says what to remove; the permitted list says what to put in its place. Without the permitted list the model fills the gap with the next most probable AI word.

### Permitted (house vocabulary)

**Verbs of doing and claiming.** consider, present, show, propose, assume, define, derive, formulate, introduce, evaluate, assess, investigate, examine, explore, indicate, suggest, illustrate, demonstrate, reveal, imply, allow, provide, offer, support, enable, accommodate, render, circumvent, exhibit, employ, entail, cope with, deal with, address, tackle, capture, reflect, incorporate, account for, argue, hypothesize, we believe.

**Connectives.** However; While, Although, Whereas (one per sentence); Hence, Therefore, Thus, Consequently, Accordingly; Nevertheless, Nonetheless; Firstly, Secondly, Thirdly, Finally; In particular, More specifically; For example, For instance, e.g., i.e., namely, so-called; with respect to, in terms of, regarding; in the sense that, as a means to; stems from, arises from, results in, leads to.

**Nouns.** approach, model, method, methodology, scheme, procedure, algorithm, formulation, mechanism, implication, contribution, perspective, context, a range of, in the literature, to the best of our knowledge, is characterized by, is concerned with, acts as.

**Adjectives.** main, key, particular, specific, overall, detailed, relevant, appropriate, suitable, adequate, proper, essential, fundamental, substantial, considerable, sizable, straightforward, trivial, non-trivial, simple, realistic, conservative, stylized, generic, arbitrary, tailored, dedicated, useful, helpful, valuable, rich, richer.

**Qualifiers.** largely, reasonably, rather, quite, essentially (kept when removing them changes the claim; replaced by a number when one exists).

**Genre phrases.** "In this paper, we ...", "The paper is organized as follows", "In this section, we ...", "This is in contrast with X (year), which ...", "in recent years" and "increasing attention" (once per introduction, with a citation).

### Limited (allowed, flag when overused)

| Term | Limit |
|---|---|
| Furthermore, Moreover, In addition, Additionally | one additive opener per paragraph; never two in a row |
| underline, stress, emphasize | once per section; "underlines the importance of" is banned |
| important | once per paragraph; prefer saying why it matters |
| interesting | say what is interesting about it |
| framework | only for a set of models used together; otherwise "model" or "approach" |
| insight | one per section; name the insight |
| state-of-the-art | name the method instead |
| synergy | only when two effects reinforce each other; not as decoration |
| concerning | prefer "about" or "regarding" |
| significant, robust | only in the statistical, mathematical, or optimization sense |

### Banned

**Verbs.** highlight, utilize, facilitate, harness, tap into, leverage, navigate, foster, unlock, delve, unpack, showcase, illuminate, underscore.

**Adjectives.** crucial, novel, comprehensive, sophisticated, elegant, intricate, promising, powerful, versatile, seamless, holistic, nuanced, pivotal, compelling, transformative, multifaceted, cutting-edge, game-changing, groundbreaking, real-world, load-bearing (non-structural), X-aware compounds (context-aware, uncertainty-aware) unless an established technical term. Intensifiers highly, very, extremely before an adjective.

**Nouns.** landscape, ecosystem, realm, paradigm, interplay, trade-off space, design space, pipeline (non-software).

**Phrases.** it is worth noting that, it should be noted that, importantly, notably, at its core, needless to say, in today's rapidly evolving, sheds light on, offers a lens, raises important questions, serves as a, represents a significant, plays a (crucial) role, not only ... but also, rather than simply, more than just, gives rise to, draws on, builds on, a variety of, a number of, while prior work has, unlike existing methods, we now turn to, before proceeding it is useful to note, in order to (use "to"), due to the fact that (use "because"), certainly, absolutely, going forward, in conclusion.

### Substitution table

| Avoid | Replace with |
|---|---|
| underlines the importance of X | This result implies that X has a large effect on ...; This finding suggests ... |
| highlight | show, indicate, illustrate |
| utilize | use, employ |
| facilitate | allow, enable |
| crucial | essential, necessary |
| novel | (drop; the contribution list says what is new) |
| significant (non-statistical) | substantial, considerable, sizable, large |
| a number of / a variety of | several, or the number |
| real-world | empirical, observed, or name the data |
| plays a role | (say what it does) |
| serves as | is |
| it is worth noting that | (state the sentence) |
| This implies (bare) | This finding implies, This result implies, The model implies |
| While prior work has ... | (own contribution first, then "This is in contrast with X (year), which ...") |
| not only ... but also | and, or two sentences |
| in order to | to |
| due to the fact that | because |

---

## Natural academic writing (anti-LLM pass)

Write like the author of the five papers above, not like an AI assistant. Generic AI prose reads as promotion and compression: it announces importance instead of demonstrating it, and it packs two ideas into one sentence with a colon or a dash.

**The recognizable LLM patterns to remove:**
- Colon-compressed sentences and em-dash connectors (see "Explain, do not compress").
- Short paragraphs of 3 to 4 sentences, one point each.
- Bare "This implies / This highlights / This underscores" openers.
- "While prior work ... our approach ..." and "Unlike existing methods ...".
- Three-item lists assembled for cadence with no content.
- "Not only ... but also," "rather than simply," "more than just".
- Per-comment thanks in reviewer responses ("insightful", "valuable").
- Template abstracts of five one-sentence slots.
- Bold paragraph headers (`\textbf{}`) in manuscripts.
- Vocabulary from the banned list, and any non-technical word absent from the author's papers.

**Do not simplify into plainness.** The register is formal and precise, at the level of a strong journal. "Circumvent", "render", "entail", "accommodate", "stringent", "with respect to" are the author's words and stay. "Get around", "give", "handle" are too colloquial. The fix for a banned word keeps the register: "This result implies that prioritization schemes have a large effect on the outcome", not "This shows that the choice matters".

**Preserve technical terminology, equations, and claims.** The pass is stylistic: no claim gets weakened, strengthened, or re-scoped, and no equation or defined term is touched.

**Final pass.** After editing, reread every sentence and flag any that still sounds generic, promotional, compressed, or recognizably LLM-written. Rewrite it by naming the concrete subject, putting the action in a verb, and giving the reason its own clause or sentence.

## Tone

Confident, precise, unpretentious, and explanatory. The author's papers state what the model does and why, give the number, and qualify the scope once. Einstein says "We will raise this conjecture to the status of a postulate"; Akerlof says "This paper relates quality and uncertainty". Match that confidence, but at the author's own sentence length and with the author's own connectives.

---

## Decision record (grilling session, 2026-09-13)

Each pick is the author's choice between candidate sentences. Kept here so future edits to this guide do not silently reverse a decision.

| # | Question | Pick |
|---|---|---|
| 2 | Compression level | Two sentences, mechanism stated explicitly (not colon-compressed) |
| 3 | Condition or contrast | One sentence with an "Although" clause, not split |
| 4 | Additive connectives | "Furthermore" allowed; un-banned |
| 5 | Hedging | State plainly, then scope in a clause; one hedge per claim |
| 6 | Voice | "We show" default; passive not a defect where the agent is obvious |
| 7 | Meta-commentary | "In this paper, we", roadmap, and "In this section, we" all allowed |
| 8 | Enumeration | "Firstly / Secondly / Thirdly", one sentence each |
| 9 | Banned word fix | Keep the formal register ("This result implies ... prioritization schemes ..."), not the flat version |
| 10 | Latinate verbs | Keep circumvent, render, entail, accommodate, employ, exhibit |
| 11 | Colon lists | Separate sentences: "for two reasons. The first is ... The second is ..." |
| 12 | Consequence openers | "This finding implies", not bare "This implies" |
| 13 | Examples | Claim then example by default; example-first allowed in openings |
| 14 | Nominalizations | Keep technical noun phrases, put the action in a verb |
| 15 | novel / framework | Drop "novel"; "framework" only for a set of models |
| 16 | Paragraph length | 6 to 10 sentences, a complete line of argument |
| 17 | Literature contrast | Own contribution first; "This is in contrast with X (year), which ..." |
| 18 | Introduction opening | One context sentence, then "In this paper, we ..." |
| 19 | Qualifiers | Keep "largely" etc. when they change the claim; number when available |
| 20 | e.g. / i.e. / so-called | Keep; but split the sentence after the citation list |
| 21 | Length rule | Structural (two chained clauses), no word count |
| 22 | Reviewer responses | One thanks per reviewer, then "We agree / We disagree because" |
| 23 | Abstract | Narrative with the main number; template only when the venue asks |
| 24 | Intuition paragraph | What it buys us plus the mechanism, in everyday wording |
| 25 | Spelling | Follow the journal; correct Danish-English phrasings |
| 26 | AI-term mechanism | Permitted list from own papers plus banned list plus no non-corpus words |
| B1-B5 | Vocabulary and formatting batches | As listed in "Vocabulary" and "Structure"; "synergy" limited, "In this section" allowed |
| + | Sections | 5 to 6 top-level, 2 to 3 subsections each |
