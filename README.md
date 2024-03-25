
## Git init

```
echo "# rust-devcontainer" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin git@github.com:horowitzathome/rust-devcontainer.git
git push -u origin main
```