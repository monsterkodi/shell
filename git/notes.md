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

# reset directory
git checkout -- dir
git clean dir -fd

# reset submodule to remote status
git submodule update -- <path>

# set remote for local repository
git remote add origin <remote-url>
git branch --set-upstream-to=origin/master master

# change remote url
git remote set-url origin <remote-url>

# remove tag
git tag -d tag
git push origin:tag

# create github pages 
git checkout -b gh-pages
git push --set-upstream origin gh-pages

# remove github release
git tag -d v0.1.1  
git push origin :v0.1.1

```
