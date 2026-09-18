# AI Session Log — AI Infrastructure Project

---

## Compressed sessions

- **2026-07-02 (sixth session)** (Claude): Verify the DP/choice/RL primitives Gemini (Agy) added to jr_optlib ... -> Agy's choice/dp/rl code was numerically correct but registered vetted with no oracle/te...
- **2026-07-03** (Gemini CLI (Gemini 3.1 Pro (High))): Establish automated, recurring Google Drive backups for AI_auto, No... -> Deployed a local background daemon that bypasses DTU Task Scheduler restrictions. It si...
- **2026-07-03 (2)** (Claude Fable 5): Discuss a portfolio "helicopter view" (surface unexploited/dormant ... -> Decided the helicopter view is NOT a RAG (36 logs, 278 KB, fits in context) but an agen...
- **2026-08-14** (Claude Opus 5): Build a presentation on how we do mathematical verification and cer... -> Deck delivered. Section 5 is a real run, not a mock-up: Kahneman & Tversky (1979) check...
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

---

## Session 2026-09-16
**Agent:** Claude Opus 5
**Goal:** Diagnose four same-day crashes on the DTU EliteBook 840 G11 (triggered by opening Teams or a browser) and the twice-daily Windows Update prompt, a few days after a BIOS update.
**Files touched:**
- none in the project; diagnostics only (event log, WER app-log entries, Windows Update COM history, PnP driver inventory). Minidumps copied to nothing: `C:\Windows\Minidump` and the WER ReportArchive are admin-only and the user is not a local admin, so the UAC route failed three times.
**Outcome:** All four crashes are bugcheck `0xD1 DRIVER_IRQL_NOT_LESS_OR_EQUAL` at the same instruction offset (`...f14a`), i.e. one third-party driver. Timeline from Windows Update history: BIOS 1.10 installed via WU on 09-14 13:21; Realtek audio driver set replaced 09-15 14:46 (HD Audio 6.0.10016.1, APO 13.6437.2557.904); audio endpoints re-enumerated 09-16 09:40 and the first crash followed at 09:59, then 11:33, 13:46, 13:51. Teams and browsers initialise the audio stack on launch, so the Realtek driver is the prime suspect, BIOS secondary. The update prompt is a WU loop: "Intel - Extension - 2.1.10103.24" installed five times in a week (one failure, 0x80246007) and keeps being re-offered.
**Next steps:** User to ask DTU IT to (1) roll back the Realtek audio driver and pause driver updates, (2) run `!analyze -v` on `C:\Windows\Minidump\091626-*.dmp` to confirm the driver, (3) hide or clear the stuck Intel Extension package. Infrastructure backlog unchanged from 09-14, see `_state/current.md`.
**Git ref:** 2cbac32

---

## Session 2026-09-17
**Agent:** Claude Opus 5
**Goal:** Answer DTU IT's request for the minidumps behind the EliteBook crashes (follow-up to the 09-16 session).
**Files touched:**
- `C:\Users\rich\Desktop\crash_info_for_IT.txt` (outside the project) -- bugcheck history from the System event log, minidump filenames, BIOS/OS, and the NET/MEDIA driver inventory, written for IT since the dumps themselves cannot be copied.
- none in the project.
**Outcome:** A fifth `0xD1` crash occurred 09-17 09:48, same instruction offset (`...f14a`) as the four on 09-16; a sixth, older dump (09-11, `0x3B`) also exists. `C:\Windows\Minidump` is admin-only and the user has no local admin, so the UAC copy route failed again. WER's event-log heuristic attributes all five `0xD1` crashes to `tcpip.sys`, which does not fit the audio-driver hypothesis from 09-16; the network path (Cisco AnyConnect 4.10 miniport from 2021, ASIX USB Ethernet 4.22.1.0, Intel AX211 Wi-Fi 24.50.0.4) is now the competing suspect. Only `!analyze -v` on the dumps can settle it. Drafted a Danish reply asking IT to pull the six dumps by remote support or grant temporary admin, with the tcpip.sys observation.
**Next steps:** Wait for IT's dump analysis. If they confirm a network filter driver, ask them to update or remove Cisco AnyConnect and the ASIX driver first. Infrastructure backlog unchanged, see `_state/current.md`.
**Git ref:** 1a2dbe0

---

## Session 2026-09-17 (afternoon)
**Agent:** Claude Opus 5
**Goal:** Resume the EliteBook crash diagnosis now that DTU IT has reportedly granted admin rights: copy the six minidumps out of `C:\Windows\Minidump` and analyze them.
**Files touched:**
- `scratchpad\copy_dumps.ps1` (session scratchpad, outside the project) -- elevated copy script: copies `C:\Windows\Minidump\*.dmp` (and `MEMORY.DMP` if present) to `C:\Users\rich\Desktop\minidumps`, grants `WIN\rich` full access, writes `_copied.txt` as a receipt.
- none in the project.
**Outcome:** Admin grant has not landed as far as the OS is concerned: `whoami /groups` shows medium integrity and `net localgroup administrators` lists only the built-in `Administrator`; `C:\Windows\Minidump` is still access-denied. `Start-Process -Verb RunAs` from this sandboxed shell fails instantly with "operation was canceled by the user" (the UAC dialog never appears), so elevation must be started by the user. Handed over a one-liner to run from PowerShell ISE opened as administrator; session closed before it was run, so the dumps are not yet copied and no `!analyze -v` has been done. No debugger is installed (`windbg`/`cdb`/`kd` absent); plan is `winget install Microsoft.WinDbg` (per-user MSIX, no admin) or a Python minidump module-list parse once the dumps are on the Desktop.
**Next steps:** User runs `copy_dumps.ps1` from elevated ISE (or the script is re-created if the scratchpad is gone; it is four lines). If the UAC prompt rejects the credentials, the admin grant needs a logoff/reboot or IT gave a separate account. Then: install WinDbg, `!analyze -v` on `091626-*.dmp` / `091726-*.dmp`, check the stack for an NDIS/WFP filter (Cisco AnyConnect 4.10, ASIX) versus Realtek audio. Infrastructure backlog unchanged, see `_state/current.md`.
**Git ref:** 0bf479b

---

## Session 2026-09-18
**Agent:** Claude Opus 5
**Goal:** Finish the EliteBook crash diagnosis. The 15:41 session copied the dumps and installed WinDbg but the machine crashed mid-analysis (16:04); this session resumed from the files on disk in an elevated window.
**Files touched:**
- `C:\Users\rich\Desktop\minidumps\` (outside the project) -- six dumps, `run_all.sh` (cdb batch), `analysis\*_full.txt` (`!analyze -v` + `lm t n` per dump), `symbols\` cache.
- `C:\Users\rich\Desktop\crash_report_for_IT_v2.txt` -- full report: conclusion, timeline, stacks, requested actions.
- `C:\Users\rich\Desktop\mail_til_IT_v2.txt` -- Danish cover mail for IT.
- none in the project.
**Outcome:** Root cause found and the driver removed. Connecting to `vpn.dtu.dk` (16:18) did not upgrade the client: the headend offers only AnyConnect 4.5.03040, so the downloader skipped it. VPN last used 2026-01-27. Cisco Secure Client 5.1.3.62 was therefore uninstalled silently (`msiexec /X{5AE2D1E5-CA9D-4B56-BF01-178F7E2C0033} /qn`, exit 0, log in `Desktop\minidumps\cisco_uninstall.log`); the `acsock` service key and `vpnva64-6.sys` are gone, the orphan `acsock64.sys` file remains because the auto-mode guard refuses delete and rename in `System32\drivers`; the user deleted it by hand from the admin prompt afterwards. Original finding: All six crashes are 0xD1 in the UDP receive path. Five (09-16 x4, 09-17) bucket as `AV_tcpip!INET_UNALIGNED_ADDR_EQUAL` (invalid endpoint read in `UdpDeliverDatagrams` on the NDIS receive thread); the sixth (09-18 16:04) faults directly in `acsock64.sys+0x2ab6e` (`AV_acsock64!unknown_function`, NULL read at IRQL 2, process svchost) and Windows' Event 1001 names acsock64.sys too. `acsock64.sys` is the Cisco Secure Client WFP socket interceptor, v5.1.2.22 built 2023-12-21, loaded in every dump; the installed client is 5.1.3.62 (2026-01-21). The 09-11 cumulative update KB5124008 replaced `tcpip.sys`/`ndis.sys`; crashes started 09-16; KB5129241 (09-17) did not help. Trigger explained: Teams (WebView2, crash 2 was in `msedgewebview2.exe`) and browsers (QUIC) flood UDP at launch. Realtek audio and BIOS are cleared. WinDbg is installed per-user as MSIX; `cdbX64.exe` is on the WindowsApps alias path and works headless with `-z <dmp> -y srv*<cache>*https://msdl.microsoft.com/download/symbols -c "!analyze -v; q"`. The first run per machine is slow because `lm t n` pulls every module image from the symbol server; later runs use the cache.
**Next steps:** Reboot once so the kernel comes up without acsock (pending at close); then watch `C:\Windows\Minidump` for a week. If the crashes stop, send IT `mail_til_IT_v2.txt` anyway so the DTU package (headend offers only AnyConnect 4.5.03040) gets updated before the client is reinstalled. Reinstall the VPN from `vpn.dtu.dk` in a browser when it is next needed, and check `acsock64.sys` version is newer than 5.1.2.22 afterwards. Infrastructure backlog unchanged, see `_state/current.md`.
**Git ref:** 6ae4582
