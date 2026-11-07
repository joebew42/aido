---
description: Resolves database migration conflicts after rebasing with main/master, for any migration tool. Invoked when the user has a schema or migration conflict after rebase, two migrations claiming the same position, or runs /aido:resolve-migration-conflict.
disable-model-invocation: false
---

# Resolve Migration Conflict

In Copilot CLI, **before any other action**, resolve `${CLAUDE_PLUGIN_ROOT}` as two directories above
the skill base directory, then load `${CLAUDE_PLUGIN_ROOT}/guidelines/copilot-cli.md` and follow it.

Resolve database migration conflicts after a rebase onto the main/master branch. The steps work with
any migration tool. The commands come from the host repository.

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` and follow it in everything you write for a person.

## When to Use This Skill

Use this skill when:

- your PR has been open for a while
- another PR with a migration was merged to main/master
- after a rebase, a generated schema snapshot conflicts, or your migration is no longer the latest
- the migration tool reports two migrations at the same position, or more than one "head"

## Step 0: Learn the Project's Migration Tooling

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md`. Gather the host repository's conventions as
`${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md` describes. From its agent instruction files,
docs, scripts and existing migrations, find out:

- **the commands** to apply migrations, roll back the latest one, and prepare the test database
- **where migrations live**, and how they are named
- **how order is decided**, one of two ways:
  - **by name**: a timestamp or sequence number in the file name, or in a version field, decides the
    order
  - **by parent reference**: each migration names the migration it follows, as a parent revision or
    a dependency list. Together they form a chain
- **whether a schema snapshot is generated and committed**: a file the tool rewrites after every
  migration, describing the whole current schema

If you can't find one of these, ask the user with `AskUserQuestion`. Don't guess commands that change
the database.

Show what you found in a few lines before going on.

## Step 1: Roll Back Your Migration

**Checklist:**

- [ ] roll back your migration in the local database with the project's rollback command
- [ ] check that the rollback worked, with the tool's status command or the schema snapshot
- [ ] confirm the local database is back in its state before the migration

Roll back **before** the rebase. Once main's migrations are in your branch, the tool may no longer
roll back yours cleanly.

## Step 2: Isolate the Migration into Its Own Commit

Make sure your migration sits in a commit of its own, with no schema snapshot changes in it.

**Checklist:**

- [ ] find the commit that holds your migration, such as with `git log --oneline`
- [ ] start an interactive rebase to the commit before it: `git rebase -i <commit-before-migration>`
- [ ] mark the migration commit as `edit`
- [ ] when the rebase pauses there, soft-reset it: `git reset HEAD~1`
- [ ] if the project commits a schema snapshot, restore it to its state before the migration:
      `git checkout HEAD -- <schema-snapshot>`
- [ ] stage and commit only the migration file(s): `git add <migration-file> && git commit -m "<original message>"`
- [ ] continue the rebase: `git rebase --continue`

Not every environment supports an interactive rebase. If it isn't available, ask the user to run
this step. Or, while history is unpushed, rebuild the commits with `git reset` and fresh commits.

## Step 3: Rebase Against Latest Main

**Checklist:**

- [ ] fetch the latest changes: `git fetch origin`
- [ ] rebase on top of the latest default branch: `git rebase origin/<default-branch>`
- [ ] resolve conflicts in application code
- [ ] if the schema snapshot still conflicts, take main's version. Step 5 regenerates it

## Step 4: Move Your Migration After Main's

Put your migration after every migration that landed on main.

**Ordered by name:**

- [ ] give your migration a new timestamp or sequence number, later than every existing migration,
      in the format the existing ones use
- [ ] rename the file. If the tool keeps a version inside it, update that too
- [ ] keep everything else the same: only the order changes

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
      unmerged. It keeps history linear

## Step 5: Apply Migrations

**Checklist:**

- [ ] apply migrations with the project's command
- [ ] check that they apply, in the expected order
- [ ] if a schema snapshot is committed, check that it now has **both** the changes from main's
      migrations and yours, and no conflict markers

## Step 6: Commit Changes

**Checklist:**

- [ ] stage the moved migration file(s)
- [ ] stage the regenerated schema snapshot, if the project commits one
- [ ] commit as `git-workflow.md` describes

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

**Before calling this done:**

- [ ] roll back your migration, then apply it again. Both work
- [ ] the test database is prepared the way the project documents
- [ ] "Before Every Commit" in `git-workflow.md` holds

## Wrap Up

Once every quality check passes:

1. run `/aido:3-organize-commits` to reorganize the commit history, without its offer to open the PR
2. once the commits are organized, say that this rewrites the history of `origin/<branch-name>`. Then
   run `git push --force origin <branch-name>`. The permission prompt asks for the user's approval, as
   "Pushing Changes" in `git-workflow.md` describes
3. end as "Ending a Skill" in `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes, also when the
   skill stops early

## Common Issues

**Migration fails after moving it**

- check that nothing taken from the file name, such as a class or module name, changed with the
  rename
- check that what your migration depends on, such as tables, columns or other migrations, still
  exists after main's changes

**Schema snapshot conflicts persist**

- make sure you rolled back **before** rebasing
- make sure your migration is now truly the latest, or the single head of the chain

**Tests fail after migrating**

- prepare the test database again with the project's command
- look for tests that depend on migration order or on data the merged migration changed
