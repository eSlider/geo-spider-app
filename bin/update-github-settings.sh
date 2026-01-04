#!/bin/bash
# Update GitHub repository "about" section and settings
# Usage: ./bin/update-github-settings.sh

set -euo pipefail

REPO="eSlider/geo-spider-app"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Check if gh CLI is authenticated
if ! gh auth status &>/dev/null; then
    warn "GitHub CLI is not authenticated."
    echo "Please run: gh auth login"
    exit 1
fi

info "Updating GitHub repository settings for: $REPO"
echo ""

# Repository description
DESCRIPTION="A sophisticated GPS/GLONASS location tracking Android application built with Kotlin Multiplatform and Jetpack Compose."

# Topics/tags
TOPICS=(
    "android"
    "kotlin"
    "kotlin-multiplatform"
    "jetpack-compose"
    "gps"
    "location-tracking"
    "glonass"
    "material-design-3"
    "gradle"
    "github-actions"
    "ci-cd"
)

info "Setting repository description..."
gh repo edit "$REPO" --description "$DESCRIPTION" || {
    warn "Failed to update description"
}

info "Setting repository topics..."
for topic in "${TOPICS[@]}"; do
    gh repo edit "$REPO" --add-topic "$topic" || {
        warn "Failed to add topic: $topic"
    }
done

info "Repository settings updated!"
echo ""
info "Current repository information:"
gh repo view "$REPO" --json description,homepageUrl,repositoryTopics,isPrivate,visibility,defaultBranchRef | jq '{
    description,
    homepageUrl,
    topics: [.repositoryTopics[].name],
    isPrivate,
    visibility,
    defaultBranch: .defaultBranchRef.name
}'

echo ""
info "To update additional settings manually:"
echo "  gh repo edit $REPO --help"
echo ""
echo "Common settings you might want to update:"
echo "  --homepage-url <url>     # Set website URL"
echo "  --enable-issues           # Enable issues"
echo "  --enable-projects      # Enable projects"
echo "  --enable-wiki              # Enable wiki"
echo "  --enable-discussions      # Enable discussions"
echo "  --default-branch <name>   # Set default branch"


