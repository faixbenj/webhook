# 🔧 GitHub Configuration Steps

## Step 3: Create Personal Access Token

1. **Go to GitHub Settings**:
   - Click your profile picture → Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Click "Generate new token (classic)"

2. **Configure the token**:
   - **Note**: `Webhook Monitor CI/CD Token`
   - **Expiration**: Choose your preference (90 days, 1 year, or no expiration)
   - **Scopes**: Select these checkboxes:
     - ✅ `repo` (Full control of private repositories)
     - ✅ `write:packages` (Upload packages to GitHub Package Registry)
     - ✅ `workflow` (Update GitHub Action workflows)

3. **Generate and copy the token**:
   - Click "Generate token"
   - **⚠️ IMPORTANT**: Copy the token immediately - you won't see it again!

## Step 4: Add Repository Secret

1. **Go to your main repository**: https://github.com/faixbenj/webhook-monitor
2. **Navigate to Settings**:
   - Repository → Settings → Secrets and variables → Actions
3. **Add new repository secret**:
   - Click "New repository secret"
   - **Name**: `HELM_REPO_TOKEN`
   - **Secret**: Paste the token you just created
   - Click "Add secret"

## Step 5: Create Helm Repository

1. **Create the repository on GitHub**:
   - Go to https://github.com/new
   - **Repository name**: `webhook-monitor-helm`
   - **Description**: `Helm charts for the Webhook Monitor application`
   - **Visibility**: Public
   - ✅ Add a README file
   - Click "Create repository"

2. **Push your local helm repo**:
   ```bash
   cd c:\git\webhook-helm-repo
   git init
   git add .
   git commit -m "🎉 Initial Helm charts repository"
   git branch -M main
   git remote add origin https://github.com/faixbenj/webhook-monitor-helm.git
   git push -u origin main
   ```

## Step 6: Enable GitHub Pages

1. **Go to the helm repository**: https://github.com/faixbenj/webhook-monitor-helm
2. **Navigate to Settings**:
   - Repository → Settings → Pages
3. **Configure Pages**:
   - **Source**: "Deploy from a branch"
   - **Branch**: `gh-pages`
   - **Folder**: `/ (root)`
   - Click "Save"

## Step 7: Test the Pipeline

```bash
# In your main repository (c:\git\webhook)
git tag v0.1.0
git push origin v0.1.0
```

Then monitor:
- https://github.com/faixbenj/webhook-monitor/actions
- https://github.com/faixbenj/webhook-monitor-helm/actions

---

**Next**: Run these commands when you're ready to test!