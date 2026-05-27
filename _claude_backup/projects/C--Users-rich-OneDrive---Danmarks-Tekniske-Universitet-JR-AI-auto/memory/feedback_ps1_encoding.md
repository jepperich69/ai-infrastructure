---
name: PowerShell script encoding — curly quote bug
description: Edit and Write tools write UTF-8 BOM and may emit curly quotes; both break tools that require clean ASCII/UTF-8 at file start
type: feedback
originSessionId: a779e717-0020-4203-9feb-7a7a3f4597d4
---
The Edit and Write tools on Windows write files with a **UTF-8 BOM** (`EF BB BF`) and may encode ASCII double quotes as Unicode smart quotes (`"` U+201C / `"` U+201D).

**BOM issue:** Any tool that expects a file to start at byte 0 with specific content (YAML `---`, shebangs, etc.) will fail silently. Codex SKILL.md files rejected as "missing YAML frontmatter" despite having `---` are almost certainly BOM-prefixed.

**Curly quote issue:** PowerShell's parser only accepts ASCII `"` as string delimiters; smart quotes cause cryptic parse errors.

**Why:** Default Windows PowerShell encoding writes UTF-8 BOM; the Read tool renders BOM and smart quotes identically to their ASCII counterparts, making the bug invisible in conversation.

**How to apply — strip BOM from any file (use after writing SKILL.md, .ps1, or any format-sensitive file):**

```powershell
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$bytes = [System.IO.File]::ReadAllBytes($path)
if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    $text = [System.Text.UTF8Encoding]::new($true).GetString($bytes)
    [System.IO.File]::WriteAllText($path, $text, $utf8NoBom)
}
```

**How to apply — fix curly quotes in .ps1 files:**

```powershell
$f = 'path\to\script.ps1'
$c = [IO.File]::ReadAllText($f, [Text.Encoding]::UTF8)
[IO.File]::WriteAllText($f, ($c -replace [char]0x201C,'"' -replace [char]0x201D,'"' -replace [char]0x2018,"'" -replace [char]0x2019,"'"), [Text.Encoding]::UTF8)
```

Do both proactively after any Edit/Write to `.ps1` or SKILL.md files. For batch BOM removal across a directory, loop with `Get-ChildItem -Recurse`.
