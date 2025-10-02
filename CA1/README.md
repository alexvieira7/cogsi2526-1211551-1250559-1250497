# CA1 - Version Control

Version Control is fundamental to software development, it allows to manage code edits in a collaborative way and organized. Git was the asked tool to be used and in the end of this report we analyse Mercurial, an alternative tool to version control, and also impplement it.

---

## Part 1 — Without Branches (Git)

Initial configuration:

```bash
git config --global [user.name](http://user.name) "Name"
git config --global [user.email](http://user.email) "name@mail.com"
git config --global core.editor nano
```

Created and Cloned GitHub:

```bash
git clone [https://](https://github.com/isep-antoniodanielbf/cogsi2425-1190402-1200928-1222598)github.com/alexvieira7/cogsi2526-1211551-1250559-1250497
```

Copied files from CA0 and commit changes:

```bash
git add --all
git commit -m "Pasta para a CA1"
git push
```

Created tag for new version:

```bash
git tag 1.1.0
git push origin 1.1.0
```

Check history:

```bash
git log
```

Reverted commit due to an error:

```bash
git revert 4a9d8e1
```

Ended Part 1 with the creatin of the tag: 

```bash
git tag ca1-part1
git push origin --tags
```

## Part 2 - With Branches
