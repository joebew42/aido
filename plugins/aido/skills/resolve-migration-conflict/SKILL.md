---
description: Resolves database migration conflicts after rebasing with main/master, for any migration tool. Invoked when the user has a schema or migration conflict after rebase, two migrations claiming the same position, or runs /aido:resolve-migration-conflict.
disable-model-invocation: false
---

# Resolve Migration Conflict

Resolve database migration conflicts after rebasing with the main/master branch. The steps are
tool-agnostic: the commands come from the host repository.

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` and follow it in everything you write for a person.

## When to Use This Skill

Use this skill when:

- your PR has been open for a while
- another PR with a migration was merged to main/master
- you rebased and now have conflicts in a generated schema snapshot, or your migration is no longer
  the latest one
- the migration tool reports two migrations at the same position, or more than one "head"

## Step 0: Learn the Project's Migration Tooling

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md` and gather the host repository's conventions as
`${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md` describes. From its agent instruction files, docs,
scripts and existing migrations, find out:

- **the commands** to apply migrations, roll back the latest one, and prepare the test database
- **where migrations live** and how they are named
- **how order is decided** — one of two models:
  - **by name**: a timestamp or sequence number in the file name (or in a version field) decides
    the order
  - **by parent reference**: each migration declares the migration it follows (a parent revision
    or dependency list), forming a chain
- **whether a schema snapshot is generated and committed** — a file the tool rewrites after every
  migration, describing the full current schema

If any of these can't be determined, ask the user with `AskUserQuestion`. Do not guess commands that
change the database.

Present what you found in a few lines before continuing.

## Step 1: Roll Back Your Migration

**Checklist:**

- [ ] roll back your migration in the local database with the project's rollback command
- [ ] verify the rollback succeeded (the tool's status command, or the schema snapshot)
- [ ] confirm the local database is in its pre-migration state

Roll back **before** rebasing — once main's migrations are in your branch, the tool may no longer be
able to roll back yours cleanly.

## Step 2: Isolate the Migration into Its Own Commit

Make sure your migration sits in a standalone commit, with no schema snapshot changes in it.

**Checklist:**

- [ ] identify the commit containing your migration (e.g. `git log --oneline`)
- [ ] start an interactive rebase to the commit before it: `git rebase -i <commit-before-migration>`
- [ ] mark the migration commit as `edit`
- [ ] when the rebase pauses there, soft-reset it: `git reset HEAD~1`
- [ ] if the project commits a schema snapshot, restore it to its pre-migration state:
      `git checkout HEAD -- <schema-snapshot>`
- [ ] stage and commit only the migration file(s): `git add <migration-file> && git commit -m "<original message>"`
- [ ] continue the rebase: `git rebase --continue`

Interactive rebase is not supported in every environment. If it isn't available, ask the user to run
this step, or rebuild the commits with `git reset` and fresh commits while history is unpushed.

## Step 3: Rebase Against Latest Main

**Checklist:**

- [ ] fetch the latest changes: `git fetch origin`
- [ ] rebase on top of the latest default branch: `git rebase origin/<default-branch>`
- [ ] resolve conflicts in application code
- [ ] if the schema snapshot still conflicts, take main's version — it is regenerated in Step 5

## Step 4: Move Your Migration After Main's

Put your migration after every migration that landed on main.

**Ordered by name:**

- [ ] give your migration a new timestamp or sequence number later than every existing migration,
      using the format the existing migrations use
- [ ] rename the file, and update any version recorded inside it if the tool keeps one there
- [ ] keep everything else the same: only the ordering changes

```
# Before:
<migrations-dir>/20240115100000_add_user_fields.<ext>

# After:
<migrations-dir>/20240129143500_add_user_fields.<ext>
```

**Ordered by parent reference:**

- [ ] find the migration that is now the latest on main
- [ ] point your migration's parent reference at it, so the chain has a single head again
- [ ] if the tool offers a merge migration instead, prefer re-parenting while your migration is
      unmerged — it keeps history linear

## Step 5: Apply Migrations

**Checklist:**

- [ ] apply migrations with the project's command
- [ ] verify they apply successfully, in the expected order
- [ ] if a schema snapshot is committed, check it now includes **both** the changes from main's
      migrations and yours, and contains no conflict markers

## Step 6: Commit Changes

**Checklist:**

- [ ] stage the moved migration file(s)
- [ ] stage the regenerated schema snapshot, if the project commits one
- [ ] commit per the conventions in `git-workflow.md`

**Commit message:**

```
chore: resolve migration conflict after rebase
```

**Alternatives:**

```
chore: update migration order to resolve conflict
chore: rename migration after rebase with main
```

## Quality Checks (MANDATORY)

**Before considering this done:**

- [ ] roll back your migration, then apply it again — both succeed
- [ ] the test database is prepared the way the project documents
- [ ] "Before Every Commit" in `git-workflow.md` holds

## Wrap Up

Once all quality checks pass:

1. Run `/aido:3-organize-commits` to reorganize the commit history, without its offer to open the PR
2. Once commits are organized, say that this rewrites the history of `origin/<branch-name>`, then run
   `git push --force origin <branch-name>`; per "Pushing Changes" in `git-workflow.md`, the
   permission prompt asks for the user's approval
3. End as "Ending a Skill" in `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes, also when the
   skill stops early

## Common Issues

**Migration fails after moving it**

- check that nothing derived from the file name (such as a class or module name) changed with the
  rename
- check that anything your migration depends on (tables, columns, other migrations) still exists
  after main's changes

**Schema snapshot conflicts persist**

- make sure you rolled back **before** rebasing
- make sure your migration is now truly the latest, or the single head of the chain

**Tests fail after migrating**

- prepare the test database again with the project's command
- look for tests that depend on migration order or on data the merged migration changed
