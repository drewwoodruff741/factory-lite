# SPEC: <project>

Phase: pre-alpha

## Problem
<Two or three sentences. Who has the problem, what happens today, what changes when this exists.>

## Walking skeleton
The one end-to-end slice that must run before anything else.
- Input: <the smallest real input>
- Output: <the smallest observable result>
- Run with: `<one command>`
- Proven by: <the one check ./prove.sh performs, e.g. "exit 0 and the word OK in stdout">

## Pre-alpha requirements
Only what the walking skeleton above needs in order to run and be proven. Numbered; each must be
checkable — if you can't say how it would be checked, it isn't a requirement yet. Anything the
skeleton does not need goes in `## Deferred`, however sure you are that you want it. **Pre-alpha
ends when the skeleton walks, not when this list is long.**
1.
2.

## Out of scope for pre-alpha
Things you are **not building** — the ones you will be tempted by. Be explicit; a list of things
you never wanted is decoration.
-
-

## Constraints (cannot change)
-

## Deferred
Things you **are** building, just not in pre-alpha: scope cut from the requirements above when this
spec was written, plus ideas that surface during the build. Do not build any of it in pre-alpha.
`/factory-lite:harden` turns this into a ranked backlog and asks for evidence per item.

(The difference from "Out of scope": that list is refusals, this one is a queue. Nothing belongs on
both.)
-
