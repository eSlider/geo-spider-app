# GitHub Repository Settings

This document describes the recommended GitHub repository settings for Geo Spider App.

## About Section

### Description
```
A sophisticated GPS/GLONASS location tracking Android application built with Kotlin Multiplatform and Jetpack Compose.
```

### Topics/Tags
- `android`
- `kotlin`
- `kotlin-multiplatform`
- `jetpack-compose`
- `gps`
- `location-tracking`
- `glonass`
- `material-design-3`
- `gradle`
- `github-actions`
- `ci-cd`

### Website (Optional)
Leave empty or set to project documentation URL if available.

## Repository Settings

### General Settings

**Features:**
- ✅ Issues: Enabled (for bug reports and feature requests)
- ✅ Projects: Optional (for project management)
- ✅ Wiki: Disabled (documentation is in repo)
- ✅ Discussions: Optional (for community discussions)
- ✅ Sponsors: Optional (if accepting sponsorships)

**Default Branch:**
- `main`

**Branch Protection:**
- Require pull request reviews before merging
- Require status checks to pass before merging
- Require branches to be up to date before merging
- Include administrators

### Actions Settings

**General:**
- ✅ Allow all actions and reusable workflows
- ✅ Allow actions created by GitHub
- ✅ Allow Marketplace actions by verified creators
- ✅ Allow actions by Marketplace verified creators

**Workflow permissions:**
- Read and write permissions (for creating releases and tags)
- Allow GitHub Actions to create and approve pull requests: Optional

**Artifact and log retention:**
- Build logs: 7 days (configured in workflow)
- Artifacts: 30 days (configured in workflow)

## Updating Settings

### Using GitHub CLI

1. Authenticate:
   ```bash
   gh auth login
   ```

2. Run the update script:
   ```bash
   ./bin/update-github-settings.sh
   ```

### Manual Update

1. Go to repository Settings
2. Navigate to "General" section
3. Update "About" section:
   - Description
   - Topics
   - Website (optional)
4. Configure features (Issues, Projects, Wiki, etc.)
5. Set branch protection rules if needed

## Recommended Branch Protection Rules

For the `main` branch:
- Require pull request reviews (1 approval minimum)
- Require status checks to pass:
  - Build Android APK
- Require branches to be up to date before merging
- Do not allow force pushes
- Do not allow deletions

## Security Settings

- Enable dependency graph
- Enable Dependabot alerts
- Enable Dependabot security updates
- Enable secret scanning
- Enable code scanning (if using CodeQL)

