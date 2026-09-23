# AI Session Log — AI Infrastructure Project
---

## Compressed sessions

- **2026-08-18** (Codex): Build a shorter, popular mathematical-verification deck with anonym... -> Delivered a 16-slide popular talk. The anonymous sample illustrates three distinct prin...
- **2026-08-27** (Claude Opus 5): Design and build an instruction set (skill) for refereeing and edit... -> /review-paper is live. It extends the user's eight criteria with venue fit, claim-evide...
- **2026-08-27** (Claude Opus 5): Decide how QGIS should fit the JR structure, and implement it. -> QGIS is a per-project tool, not a project type. No standing QGIS folder: `helpi 28` add...
- **2026-08-27 (2)** (Claude Opus 5): Install Biogeme for discrete choice, then make tool tracking surviv... -> Biogeme 3.3.4 installed outside OneDrive and validated against the published Swissmetro...
- **2026-09-03** (Claude Opus 5): Make math render legibly in the Claude Code terminal instead of raw... -> Two-tier math display. The claude-math plugin (third-party, model-invoked skill, no exe...
- **2026-09-03** (Claude Opus 5): Get voice input working in the Claude Code CLI, expected to need a ... -> No plugin needed or possible. Dictation is native since v2.x (`/voice`, hold or tap); p...
- **2026-09-03** (Codex): Strengthen the `review-paper` skill against ghost references and ci... -> Full reviews and revision rounds must now verify every bibliography entry rather than s...
- **2026-09-04** (Claude Opus 5): Stop the CLI agents from producing long, hard-to-digest answers; ma... -> The rule is live for all three CLIs everywhere. Regeneration ran `generate_handover.ps1...
- **2026-09-04** (Codex): Bring the infrastructure guide and GitHub README up to date, replac... -> The guide now reflects the September 2026 infrastructure. The full PDF has a clean vers...
- **2026-09-11** (Claude Opus 5): Fold a "Natural Academic Writing" rule set (anti-LLM vocabulary and... -> The style rules now name the AI tells explicitly (load-bearing, aware-compounds, robust...
- **2026-09-13** (Claude Opus 5): Recalibrate the research writing style guide against the author's o... -> The guide is now calibrated on the author's own five papers rather than on Einstein, Ak...
- **2026-09-14** (Claude Opus 5): Recover and log the unlogged 2026-09-13 sessions (here and in `Pub_... -> Both 2026-09-13 sessions are on record. The style pass was applied to v10 and pushed (O...
- **2026-09-16** (Claude Opus 5): Diagnose four same-day crashes on the DTU EliteBook 840 G11 (trigge... -> All four crashes are bugcheck `0xD1 DRIVER_IRQL_NOT_LESS_OR_EQUAL` at the same instruct...
- **2026-09-17** (Claude Opus 5): Answer DTU IT's request for the minidumps behind the EliteBook cras... -> A fifth `0xD1` crash occurred 09-17 09:48, same instruction offset (`...f14a`) as the f...
- **2026-09-17 (afternoon)** (Claude Opus 5): Resume the EliteBook crash diagnosis now that DTU IT has reportedly... -> Admin grant has not landed as far as the OS is concerned: `whoami /groups` shows medium...
- **2026-09-18** (Claude Opus 5): Finish the EliteBook crash diagnosis. The 15:41 session copied the ... -> Root cause found and the driver removed. Connecting to `vpn.dtu.dk` (16:18) did not upg...

---

## Session 2026-09-18 (evening)
**Agent:** Claude Opus 5
**Goal:** Explain and fix the Windows Update prompt that appears at every boot ("Intel - Extension - 2.1.10103.24"), left open from the crash-diagnosis sessions.
**Files touched:**
- `C:\Users\rich\Desktop\minidumps\hide_intel_ext.ps1` -- hides the looping WU package via the Update Session COM API; must be run from an elevated PowerShell.
- none in the project.
**Outcome:** Loop mechanism identified from `C:\Windows\INF\setupapi.dev.log` (11 rounds since 09-11). Each "OK" install stages `ipf_ef_ext.inf` (Intel IPF Extensible Framework Extension) as `oem337.inf`, PnP lists it as Selected for the IPF device `PCI\VEN_8086&DEV_7D03` but cannot bind its install section against base driver `ipf_cpu.inf` 2.3.20300.4905 (installed by HP/WU on 09-14), configures the device with only `oem321`+`oem211`+`oem314`, then deletes the unreferenced package 40 s later (`Delete flags 0x2`). WU records exit 0, the device still lacks extension ID `{002c4697-...}`, and the package is re-offered at the next scan. The package therefore never appears in the PnP driver inventory. It is an Intel/HP catalog mismatch, harmless; hiding the package is the fix. Also observed: the machine has not been rebooted since the 16:04 crash (`PendingFileRenameOperations` set), so the post-Cisco reboot is still outstanding. Six other driver updates queued (Realtek, HP keyboard/software component, Cirrus Logic, Logitech) are one-shot, not part of the loop.
**Next steps:** Package hidden by the user (verified: WU lists it under IsHidden=1, no longer offered). Reboot still outstanding. Machine watch and IT mail as in the previous session. Infrastructure backlog unchanged, see `_state/current.md`.
**Git ref:**

---

## Session 2026-09-23
**Agent:** Gemini CLI (Gemini 3.1 Pro (High))
**Goal:** Install a new A0 printer in Building 358, room 161.
**Files touched:**
- none in the project.
**Outcome:** Located the new plotter on the DTU print server (`\\ait-print\LY358-161A-POSTER`) and installed it on the local machine. The printer failed to print via the server because the LAN port in room 161 is dead (printer pulled APIPA `169.254.24.233`). Instructed the user to connect via Wi-Fi Direct (`Direct-D4-HP DesignJet T850`) using the security key instead of the WPS PIN.
**Next steps:** User to contact DTU IT to activate the LAN wall port in Building 358 room 161 so the printer can join the DTU network.
**Git ref:**

---

## Session 2026-09-23 (2)
**Agent:** Claude Opus 5.5
**Goal:** Get the new A0 poster printer (HP DesignJet T850, `\ait-print\LY358-161A-POSTER`, Bldg 358 rm 161A) working after the Gemini/AGY session.
**Files touched:**
- none in the project. Removed the stale local connection `\ait-print\LY358-161A-CO2 (HP DesignJet T730)`.
**Outcome:** Laptop cannot join the printer's Wi-Fi Direct: DTU group policy sets a WLAN allow list (`eduroam`, `DTUsecure` only) and the DIRECT SSID is not even listed in scans. The server queue expects the T850 at `10.196.0.196` (unreachable) and uses the wrong driver, "HP DesignJet T830 24in MFP PCL3", which may not offer A0 width. The old T730 queue (`LY358-161A-CO2`) is gone from `ait-print` (the T850 replaced it); the stale local entry was removed and could not be re-added. The T850 has no USB device port, only a USB-stick host port. Workarounds given: print an A0 PDF from a USB stick at the printer, print from a phone over Wi-Fi Direct (AirPrint/Mopria/HP Smart, fit-to-page off), or use another campus plotter (`LY325-140-POSTER` Z6, `LY345E-142-POSTER` T1500, `LY310-237A-POSTER` Z9).
**Next steps:** Mail DTU IT: activate the LAN wall port in 358/161A and switch the POSTER queue driver to a 36in T850 driver. Infrastructure backlog unchanged, see `_state/current.md`.
**Git ref:**

---

## Session 2026-09-23 (3)
**Agent:** Codex
**Goal:** Audit the AI_auto instruction, skill, and hook system against claims that newer models benefit from fewer prescriptive guardrails, while applying the mandatory infrastructure catch-up.
**Files touched:**
- `scripts/compress_log.ps1` -- preserved pre-session metadata and final `Git ref: ---` placeholders during compression.
- `scripts/compress_log_metadata_fixture.md`, `scripts/test_compress_log.ps1` -- added and passed a regression test for log compression.
- `scripts/restore.ps1`, `scripts/generate_handover.ps1`, `prompts/claude-validate-helpi25.md` -- replaced obsolete root-level script paths and added supported launcher usage.
- `known_issues.md` -- marked the log-compression and stale-close-path issues fixed.
- `~/.agents/skills/close/SKILL.md`, `~/.agents/skills/research-close/SKILL.md`, `~/.claude/CLAUDE.md` and its active backup -- corrected close paths and removed superseded workaround notices.
**Outcome:** The system remains sound in principle, but the audit found one unsafe auto-commit Stop hook, excess always-loaded context, duplicate skill aliases, and stale reminders; two open infrastructure bugs were fixed and verified in commit `f4ef133`.
**Next steps:** Ask Claude for an independent assessment of the audit. Then remove the `auto_commit_hook.ps1` Stop hook manually and, if desired, run a focused pruning pass that shortens always-loaded instructions, routes to task-specific documentation, and consolidates duplicate aliases without deleting safety or domain constraints.
**Git ref:** f4ef133

---
