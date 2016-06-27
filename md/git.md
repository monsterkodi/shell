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
git submodule update --init
#git submodule update -- <path>

# set remote for local repository
git remote add origin <remote-url>
git branch --set-upstream-to=origin/master master

# change commit message
git commit --amend -m "new message"
git push --force # if it was already pushed

# set username
git config user.name monsterkodi
git config user.email monsterkodi@gmx.net
git config -l

# change remote url
git remote set-url origin <remote-url>

# release tag
git tag -f -a -m "v1.0.1" v1.0.1
git push --tags -q 

# remove tag
git tag -d v1.0.1
git push origin:v1.0.1

# force push a tag
git push --force origin refs/tags/tag

# remove github release
git tag -d v0.1.1  
git push origin :v0.1.1

# create github pages
git checkout -b gh-pages
git push --set-upstream origin gh-pages

# git-crypt
git-crypt export-key <file>
git-crypt unlock <file>

# prepare syncing of clone and original repo (https://help.github.com/articles/configuring-a-remote-for-a-fork/)
git remote -v
git remote add upstream https://github.com/owner/repo.git
git remote -v
# sync the fork (https://help.github.com/articles/syncing-a-fork/)
git fetch upstream
git merge upstream/master

# list merged remote branches sorted by age of last commit
for branch in `git branch -r --merged | grep -v HEAD`; do echo -e `git show --format="%ci %cr %an" $branch | head -n 1` \\t$branch; done | sort -r
# as above, but unmerged
for branch in `git branch -r --no-merged | grep -v HEAD`; do echo -e `git show --format="%ci %cr %an" $branch | head -n 1` \\t$branch; done | sort -r
```
