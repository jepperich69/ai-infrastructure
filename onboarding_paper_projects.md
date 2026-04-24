# Setting up your paper projects — Rich group guide

Follow these three steps for every paper you are working on.

---

## 1. Name the Overleaf project correctly

Use this format:

```
Pub_Topic_YourInitials
```

- **`Pub_`** — always this prefix. Marks it as a paper (not a thesis, proposal, or course material).
- **`Topic`** — 1–3 words describing what the paper is about. CamelCase, no spaces.
- **`YourInitials`** — the initials of the person *driving* the paper (the one keeping it moving day-to-day).

**Examples:**

| Situation | Project name |
|---|---|
| JR drives a paper on stop geometry | `Pub_StopGeometry_JR` |
| Maria Nielsen drives a paper on population integration | `Pub_PopInt_MN` |
| Thomas Green drives a paper on e-bike adoption | `Pub_EbikeAdoption_TG` |
| JR drives a paper on nonlinear diffusion | `Pub_NonlinearDiffusion_JR` |

**Rules:**
- You do not need to know the target journal when you create the project — leave it out.
- The name describes the paper, not the destination. Do not rename if you change journal.
- If authorship order shifts, the name stays. The driver is the person responsible for progress, not the first author slot.
- If a paper splits into two, create a second project with a more specific topic name.

---

## 2. Tag the project as a paper in Overleaf

1. Find the project in your Overleaf dashboard
2. Click the tag icon next to the project name
3. Add the tag: **Papers**

This tag is how the system identifies your paper projects.

---

## 3. One project per paper

One Overleaf project = one submission. If you have a single project containing multiple papers, split them out into separate projects.

---

## What the system does for you

### Local folder creation (once onboarded)

Once the AI infrastructure is running on your machine, creating a correctly named and tagged Overleaf project is enough to trigger automatic local folder creation. The system detects the new project and provisions:

```
Pub_StopGeometry_JR/
├── Overleaf_source/
├── code/
├── data/
└── figures/
```

You then move your existing files in at your own pace.

### Existing papers

If you already have a paper in progress with a messy Overleaf name and files scattered in a local folder, you have two options:

1. **Clean break:** Rename the Overleaf project to follow the convention, let the system create the new folder structure, and migrate your files across.
2. **Link as-is:** The system can also link an existing Overleaf project to an existing local folder via the key table (`papers.csv`) — no renaming or migration required. Use this for papers that are nearly finished or where moving files is not worth the effort.

**Your only immediate job is steps 1–3.** The rest is handled once you are onboarded.
