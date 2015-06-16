### git notes

```bash
# prevent changes to be committed
git update-index --assume-unchanged <file>

# revert the unchanged flag
git update-index --no-assume-unchanged

# show all commits (if rebase lost a commit)
git reflog

# unstage files
git reset HEAD file(s)

# reset file
git checkout -- file

# reset submodule to remote status
git submodule update -- <path>

# remove github release
git tag -d v0.1.1  
git push origin :v0.1.1
```
