#!/usr/bin/env bash
# adr-status.sh — each ADR's status, layer, dates, dependencies and missing
# sections, in one pass, so a skill reads a table instead of opening every ADR
# and reading its front matter and sections per file.
#
# game-template (PDR-0006): TDRs and ADRs are graph nodes. The status is the
# front matter's `status:` (draft, review, stable, deprecated), not a
# `## Status` section; the sections are the Japanese ones of
# docs/templates/adr.md (日付, 前提のADR, ...). The last-verified date
# is the front matter's `last_verified:` (YYYY-MM-DD), not a section
# (game-template PDR-0007).
#
# Replaces the hand-run ADR reads in /architecture-decision, /architecture-review,
# /create-control-manifest, /create-epics, /create-stories, /dev-story,
# /gate-check, /code-review, /story-readiness, /adopt, /create-architecture,
# /propagate-design-change and /project-stage-detect. adr-dep-graph.sh still
# owns the dependency graph and its cycles; this script reads the same
# 前提 row (and the front matter's depends_on) the same way, so the two agree
# on every edge.
#
# EMITS OBSERVATIONS, NOT A VERDICT (CLAUDE.md, "Helpers in .claude/scripts/").
# Whether a draft or review ADR blocks a story, which sections an ADR must have, and
# what a missing 層 row means are the calling skill's rules: the skills'
# own lists of required sections disagree, so this script reports every
# section of the shipped template that is missing and leaves the choice there.
#
# Usage: bash .claude/scripts/adr-status.sh [--root DIR] [ID|PATH ...]
#   ID          ADR-0003, adr-0003 or 0003, or TDR-0001 or tdr-0001: the ADR
#               or TDR whose file name carries it. A bare number is an ADR:
#               the two kinds are numbered apart (game-template, PDR-0006)
#   PATH        an ADR or TDR file, relative to the root or absolute
#   (none)      every docs/51-tdr/tdr-*.md and docs/52-adr/adr-*.md (one
#               level, as adr-dep-graph.sh)
#   --root DIR  the project; defaults to the repo this script is in
#   -h, --help  this text
# An ADR named more than once (by ID, number or path) is reported once.
#
# Output: TSV. Counts first, then one row per TDR or ADR:
#   tdrs <n> <scope>, adrs <n> <scope>, template_sections <n> <template path>,
#   then the number of records (TDRs and ADRs together) in each status: draft,
#   review, stable, deprecated, other, no_status; then superseded, the
#   deprecated ones a later record's `supersedes` names
#   TDR|ADR <id> <path> <status> <layer> <date> <last_verified> <version>
#       <depends_on> <superseded_by> <missing> <unfilled>
#   NOT_FOUND <ID or PATH>          for an argument that names no record
# The first column is TDR for a tdr-NNNN file and ADR for an adr-NNNN file.
# CCGS's statuses map onto the front matter's: Proposed is draft or review,
# Accepted is stable, Deprecated is deprecated, Superseded is deprecated with
# a successor (superseded_by is not `-`).
# Columns (`-` means not there):
#   status        draft | review | stable | deprecated: the front matter's
#                 `status:`; OTHER for any other value; `-` when there is none
#   layer         the `**層**` row's value, or UNFILLED
#   date          the first YYYY-MM-DD under `## 日付`; `-` when the section
#                 says なし or is not there; UNFILLED otherwise
#   last_verified the front matter's `last_verified:` when it is a
#                 YYYY-MM-DD; `-` when the key is not there or has no value;
#                 UNFILLED otherwise
#   version       last_verified, else date, else `unversioned` (the rule
#                 /create-stories and /dev-story stamp stories with)
#   depends_on    every ADR-N and TDR-N on the `**前提**` row of `## 前提のADR`
#                 and in the front matter's depends_on, as adr-NNNN or tdr-NNNN,
#                 comma-separated; `none` when they name none (or the section
#                 says なし); UNFILLED while the row is the template's bracket
#                 A DDR-N there (a game design decision, docs/53-ddr/,
#                 game-template PDR-0006) is not read: it is no TDR or ADR, so
#                 an ADR naming only DDRs reads `none`. adr-dep-graph.sh lists
#                 the DDRs under DDR_DEPS
#   superseded_by the TDR or ADR whose front matter `supersedes` names this one
#                 (read from every file in the two folders)
#   missing       the template's `##` sections this ADR lacks, comma-separated
#                 (titles compared without case or a leading number)
#   unfilled      how many lines are still a [bracketed] line of the template,
#                 word for word
# An empty file is still a row: no status (`-`, counted as no_status), every
# template section missing.
#
# Exit codes: 0 every ADR asked for was read; 1 the root cannot be read;
# 2 usage error; 3 an ID or PATH named no ADR (its NOT_FOUND row is printed,
# the others are still reported). Reads only; never writes, never prompts.
#
# bash 3.2 and BWK awk safe, no Python.

set -u
# Byte semantics for awk, sort and tolower.
LC_ALL=C
export LC_ALL

ROOT_ARG=""
ARGS=""
NL='
'
while [ $# -gt 0 ]; do
  case "$1" in
    --root)
      [ $# -ge 2 ] || { echo "adr-status: --root needs a value" >&2; exit 2; }
      ROOT_ARG="$2"; shift 2 ;;
    --root=*) ROOT_ARG="${1#--root=}"; shift ;;
    -h|--help) sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -?*) echo "adr-status: unknown argument: $1 (try --help)" >&2; exit 2 ;;
    *) ARGS="$ARGS$1$NL"; shift ;;
  esac
done

if [ -n "$ROOT_ARG" ]; then
  cd "$ROOT_ARG" 2>/dev/null || { echo "adr-status: cannot read root $ROOT_ARG" >&2; exit 1; }
else
  cd "$(dirname "$0")/../.." 2>/dev/null || { echo "adr-status: cannot reach the repo root" >&2; exit 1; }
fi

# game-template (PDR-0006): TDRs and ADRs sit in a folder per kind.
TDR_DIR="docs/51-tdr"
ADR_DIR="docs/52-adr"
TEMPLATE="docs/templates/adr.md"
# adr_id PATH — adr-dep-graph.sh's id: the first adr-<digits> or tdr-<digits>
# in the name, lower case.
adr_id() { printf '%s\n' "${1##*/}" | tr '[:upper:]' '[:lower:]' | grep -oE '[at]dr-[0-9]+' | head -1; }

FILES=""; MISSED=""; SCOPE="$TDR_DIR/tdr-*.md $ADR_DIR/adr-*.md"
ALL=$({ find "$TDR_DIR" -maxdepth 1 -type f -name 'tdr-*.md' 2>/dev/null
        find "$ADR_DIR" -maxdepth 1 -type f -name 'adr-*.md' 2>/dev/null; } | sort)
# add_file PATH — onto FILES unless that file is there already, under any
# spelling (-ef: the same file, whether named by ID, ./path or absolute path).
add_file() {
  while IFS= read -r g; do
    [ -n "$g" ] && [ "$g" -ef "$1" ] && return 0
  done <<EOF
$FILES
EOF
  FILES="$FILES$1$NL"
}
if [ -z "$ARGS" ]; then
  FILES="$ALL"
else
  SCOPE="arguments"
  while IFS= read -r a; do
    [ -n "$a" ] || continue
    # A Windows path's backslashes as slashes, so its file name reads alike.
    case "$a" in [A-Za-z]:\\*) a=$(printf '%s' "$a" | sed 's|\\|/|g') ;; esac
    if [ -f "$a" ]; then add_file "${a#./}"; continue; fi
    # An ID: ADR-0003, adr-0003 or 0003 (an ADR), or TDR-0001, compared on
    # its kind and number.
    want=$(printf '%s' "$a" | tr '[:upper:]' '[:lower:]')
    kind=adr
    case "$want" in tdr-*) kind=tdr ;; esac
    want="${want#"$kind"-}"
    hit=""
    case "$want" in
      ''|*[!0-9]*) ;;
      *) while IFS= read -r f; do
           [ -n "$f" ] || continue
           n=$(adr_id "$f")
           case "$n" in "$kind"-*) n="${n#"$kind"-}" ;; *) continue ;; esac
           # Numbers compare as numbers: 3 and 0003 are one ADR.
           [ -n "$n" ] && [ "$((10#$n))" = "$((10#$want))" ] && { hit="$f"; break; }
         done <<EOF
$ALL
EOF
         ;;
    esac
    if [ -n "$hit" ]; then add_file "$hit"; else MISSED="$MISSED$a$NL"; fi
  done <<EOF
$ARGS
EOF
fi

LIST=$(printf '%s' "$FILES" | awk 'NF' )

# Which record supersedes which: "old<TAB>new" for each id in a file's front
# matter `supersedes` (inline [..] or a block list), over every file in the
# two folders, so a record named alone still learns its successor.
SUPMAP=$(printf '%s\n' "$ALL" | while IFS= read -r f; do
  [ -n "$f" ] || continue
  awk -v me="$(adr_id "$f")" '
    { sub(/\r$/, "") }
    NR == 1 { if ($0 != "---") exit; infm = 1; next }
    infm && $0 == "---" { exit }
    infm && /^[A-Za-z_]+:/ { key = $0; sub(/:.*/, "", key) }
    infm && key == "supersedes" {
      s = $0
      while (match(s, /[AaTt][Dd][Rr]-[0-9]+/)) { printf "%s\t%s\n", tolower(substr(s, RSTART, RLENGTH)), me; s = substr(s, RSTART + RLENGTH) }
    }' "$f"
done)
TPL_ARG=""
[ -f "$TEMPLATE" ] && TPL_ARG="$TEMPLATE"

# One awk over the template (when there is one) and every ADR. The heading and
# fence rules are md-section.sh's: 1-6 # and a space after at most 3 spaces of
# indent; nothing inside a ``` or ~~~ fence or an HTML comment is a heading.
# The template, then the ADRs, go to awk on stdin, never as arguments (a long
# list passes the command-line limit of some systems). Each becomes an input
# file, "./" in front of a relative one so a name like x=1.md is not read as an
# assignment; an absolute one (/..., C:/...) is opened as it is.
{ [ -n "$TPL_ARG" ] && printf '%s\n' "$TPL_ARG"; printf '%s\n' "$LIST"; } | awk 'NF { sub(/^\.\//, ""); print }' | \
TPL="$TPL_ARG" SCOPE="$SCOPE" SUPMAP="$SUPMAP" awk '
  # Git for Windows gawk reads files in text mode; BINMODE keeps the bytes.
  BEGIN {
    BINMODE = 3; tpl = ENVIRON["TPL"]; nadr = 0; ntdr = 0; nrec = 0
    nsm = split(ENVIRON["SUPMAP"], sm, "\n")
    for (i = 1; i <= nsm; i++) if (split(sm[i], sp, "\t") == 2 && !(sp[1] in supby)) supby[sp[1]] = sp[2]
    # The list arrives on /dev/stdin, named, so the main input stays the files: with
    # a bare getline, gawk read the first file as more of stdin and skipped its FNR 1.
    while ((getline f < "/dev/stdin") > 0) lst[++nlst] = f
    for (i = 1; i <= nlst; i++) ARGV[ARGC++] = (lst[i] ~ /^(\/|[A-Za-z]:)/) ? lst[i] : "./" lst[i]
    na = 1
  }
  function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
  function norm(s) {
    s = tolower(trim(s)); gsub(/[ \t]+/, " ", s)
    if (s ~ /^[0-9]+[.)]? /) sub(/^[0-9]+[.)]? /, "", s)
    return s
  }
  function fence_of(s,    n, c, k) {
    n = 0; while (n < 3 && substr(s, n + 1, 1) == " ") n++
    s = substr(s, n + 1); c = substr(s, 1, 1)
    if (c != "`" && c != "~") return ""
    k = 0; while (substr(s, k + 1, 1) == c) k++
    return (k >= 3) ? substr(s, 1, k) : ""
  }
  function closes(s, f,    n, c, k) {
    n = 0; while (n < 3 && substr(s, n + 1, 1) == " ") n++
    s = substr(s, n + 1); c = substr(f, 1, 1)
    k = 0; while (substr(s, k + 1, 1) == c) k++
    return k >= length(f) && trim(substr(s, k + 1)) == ""
  }
  function first_date(s) { return match(s, /[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/) ? substr(s, RSTART, RLENGTH) : "" }
  # Every ADR-N and TDR-N in s, as adr-N or tdr-N lower case, in order,
  # without repeats.
  function adr_ids(s,    out, seen, id) {
    out = ""; split("", seen)
    while (match(s, /[AaTt][Dd][Rr]-[0-9]+/)) {
      id = tolower(substr(s, RSTART, RLENGTH)); s = substr(s, RSTART + RLENGTH)
      if (!(id in seen)) { seen[id] = 1; out = out (out == "" ? "" : ",") id }
    }
    return out
  }
  function cell2(s,    n, c) { n = split(s, c, "|"); return n >= 3 ? trim(c[3]) : "" }
  function value_of(raw) { return (raw == "") ? "-" : raw }

  # The value of a date section: the first YYYY-MM-DD of its first line; `-` when
  # the section is not there or says なし; UNFILLED for anything else.
  function date_of(line, sname) {
    if (line == "") return (sname in has) ? "UNFILLED" : "-"
    if (first_date(line) != "") return first_date(line)
    return (line == "なし") ? "-" : "UNFILLED"
  }

  function flush(    st, w, sb, ver, miss, i, t, kind) {
    if (cur == "") return
    st = "-"; sb = "-"
    w = fm_status; gsub(/["\047]/, "", w); w = trim(w)
    if (w == "draft" || w == "review" || w == "stable" || w == "deprecated") st = w
    else if (w != "") st = "OTHER"
    cnt[st == "-" ? "no_status" : tolower(st)]++
    if (cur_id in supby) { sb = supby[cur_id]; if (st == "deprecated") cnt["superseded"]++ }
    d = date_of(date_line, "日付")
    # last_verified is a front matter key (PDR-0007): no value is `-`, a date is
    # itself, anything else is UNFILLED.
    w = fm_lv; gsub(/["\047]/, "", w); w = trim(w); if (w == "[]") w = ""
    lv = (w == "") ? "-" : ((w ~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/) ? w : "UNFILLED")
    ver = (lv ~ /^[0-9]/) ? lv : ((d ~ /^[0-9]/) ? d : "unversioned")
    # The ids come from the whole row and an ADR naming itself is dropped, as
    # adr-dep-graph.sh builds its edges; the cell decides UNFILLED versus none.
    if (dep_seen || fm_deps != "") {
      dep = ""; nd = split(adr_ids(dep_row " " fm_deps), dl, ",")
      for (i = 1; i <= nd; i++) if (dl[i] != cur_id) dep = dep (dep == "" ? "" : ",") dl[i]
      if (dep == "") dep = (substr(dep_cell, 1, 1) == "[") ? "UNFILLED" : "none"
    } else dep = "-"
    lay = (layer_seen) ? ((substr(layer_cell, 1, 1) == "[") ? "UNFILLED" : value_of(layer_cell)) : "-"
    miss = ""
    for (i = 1; i <= ntpl; i++) if (!(tsec[i] in has)) miss = miss (miss == "" ? "" : ",") ttitle[i]
    kind = (substr(cur_id, 1, 3) == "tdr") ? "TDR" : "ADR"
    if (kind == "TDR") ntdr++; else nadr++
    nrec++
    t = cur_path; gsub(/\t/, " ", t); gsub(/\t/, " ", lay)
    rows[nrec] = kind "\t" cur_id "\t" t "\t" st "\t" lay "\t" d "\t" lv "\t" ver "\t" dep "\t" sb "\t" (miss == "" ? "-" : miss) "\t" unfilled
    cur = ""
  }

  function begin(f) {
    flush()
    infence = ""; incomment = 0; sec = ""; infm = 0; fmkey = ""
    if (f == "./" tpl) { intpl = 1 } else {
      intpl = 0; cur = f; cur_path = f; sub(/^\.\//, "", cur_path)
      # The id adr-dep-graph.sh uses: the first adr-<digits> or tdr-<digits>
      # in the file name, lower case.
      b = tolower(cur_path); sub(/^.*\//, "", b); cur_id = match(b, /[at]dr-[0-9]+/) ? substr(b, RSTART, RLENGTH) : "-"
      split("", has); fm_status = ""; fm_deps = ""; fm_lv = ""; date_line = ""
      dep_seen = 0; dep_cell = ""; dep_row = ""; layer_seen = 0; layer_cell = ""; unfilled = 0
    }
  }
  # An empty file has no line, so no FNR 1: every listed file awk passed over
  # before f (all of them, for f "") is one, and is still a row.
  function reach(f) {
    while (na < ARGC && ARGV[na] != f) { begin(ARGV[na]); flush(); na++ }
    if (na < ARGC) na++
  }
  FNR == 1 { reach(FILENAME); begin(FILENAME) }
  {
    line = $0; sub(/\r$/, "", line)
    # The front matter: its status, last_verified and depends_on; no line of it
    # is a section.
    if (FNR == 1 && line == "---") { infm = 1; next }
    if (infm) {
      if (line == "---") { infm = 0; next }
      if (line ~ /^[A-Za-z_]+:/) {
        fmkey = line; sub(/:.*/, "", fmkey); v = line; sub(/^[^:]*:/, "", v)
        if (!intpl && fmkey == "status") fm_status = trim(v)
        if (!intpl && fmkey == "last_verified") fm_lv = trim(v)
      }
      if (!intpl && fmkey == "depends_on") fm_deps = fm_deps " " line
      next
    }
    if (infence) { if (closes(line, infence)) infence = ""; next }
    f = fence_of(line); if (f != "") { infence = f; next }
    cstart = incomment; rest = ""; s = line
    while (s != "") {
      if (incomment) { p = index(s, "-->"); if (p == 0) { s = ""; break } s = substr(s, p + 3); incomment = 0 }
      else { p = index(s, "<!--"); if (p == 0) { rest = rest s; s = ""; break } rest = rest substr(s, 1, p - 1); s = substr(s, p + 4); incomment = 1 }
    }
    h = line; n = 0; while (n < 3 && substr(h, n + 1, 1) == " ") n++
    h = substr(h, n + 1); k = 0; while (substr(h, k + 1, 1) == "#") k++
    if (!cstart && line !~ /^[ \t]*<!--/ && k >= 1 && k <= 6 && (length(h) == k || substr(h, k + 1, 1) == " " || substr(h, k + 1, 1) == "\t")) {
      t = trim(substr(h, k + 1)); if (t ~ /(^| )#+$/) { sub(/#+$/, "", t); t = trim(t) }
      if (k <= 2) sec = (k == 2) ? norm(t) : ""
      if (k == 2) {
        if (intpl) { if (!(norm(t) in tseen)) { tseen[norm(t)] = 1; ntpl++; tsec[ntpl] = norm(t); ttitle[ntpl] = t } }
        else has[norm(t)] = 1
      }
      next
    }
    r = trim(rest)
    if (intpl) { if (r ~ /\[/) tbr[r] = 1; next }
    if (r == "") next
    if (r in tbr) unfilled++
    # The first line of text under a field heading is its value; a > quote is
    # the template guidance, not the value.
    if (substr(r, 1, 1) != ">") {
      if (sec == "日付" && date_line == "") date_line = r
    }
    if (!layer_seen && r ~ /^\|[ \t]*\*\*層\*\*[ \t]*\|/) { layer_seen = 1; layer_cell = cell2(r) }
    if (sec == "前提のadr" && !dep_seen && r ~ /\*\*前提\*\*/) { dep_seen = 1; dep_row = r; dep_cell = cell2(r); if (dep_cell == "") dep_cell = r }
    # A section that says only なし names no dependency: none, not missing.
    if (sec == "前提のadr" && !dep_seen && r == "なし") { dep_seen = 1; dep_row = ""; dep_cell = r }
  }
  END {
    flush(); reach("")
    printf "tdrs\t%d\t%s\n", ntdr, ENVIRON["SCOPE"]
    printf "adrs\t%d\t%s\n", nadr, ENVIRON["SCOPE"]
    printf "template_sections\t%d\t%s\n", ntpl, (tpl == "" ? "-" : tpl)
    split("draft review stable deprecated other no_status superseded", names, " ")
    for (i = 1; i <= 7; i++) printf "%s\t%d\n", names[i], cnt[names[i]] + 0
    for (i = 1; i <= nrec; i++) print rows[i]
  }
'

rc=0
while IFS= read -r m; do
  [ -n "$m" ] || continue
  printf 'NOT_FOUND\t%s\n' "$m"; rc=3
done <<EOF
$MISSED
EOF
exit $rc
