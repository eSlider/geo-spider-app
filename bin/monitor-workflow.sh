#!/bin/bash
# Monitor GitHub Actions workflow status
# Usage: ./bin/monitor-workflow.sh [workflow-name]

set -euo pipefail

WORKFLOW_NAME="${1:-build-android-apk.yml}"
REPO="eSlider/geo-spider-app"

echo "Monitoring workflow: $WORKFLOW_NAME"
echo "Repository: $REPO"
echo ""

# Check if gh CLI is authenticated
if ! gh auth status &>/dev/null; then
    echo "⚠️  GitHub CLI is not authenticated."
    echo "Please run: gh auth login"
    echo ""
    echo "Or check the workflow status manually at:"
    echo "https://github.com/$REPO/actions/workflows/$WORKFLOW_NAME"
    exit 1
fi

# Get latest run
LATEST_RUN=$(gh run list --workflow="$WORKFLOW_NAME" --limit 1 --json databaseId --jq '.[0].databaseId' 2>/dev/null || echo "")

if [ -z "$LATEST_RUN" ]; then
    echo "❌ No workflow runs found for $WORKFLOW_NAME"
    exit 1
fi

echo "📊 Latest workflow run ID: $LATEST_RUN"
echo ""

# Get run details
RUN_INFO=$(gh run view "$LATEST_RUN" --json status,conclusion,name,headBranch,createdAt,url,workflowName --jq '.' 2>/dev/null)

if [ -z "$RUN_INFO" ]; then
    echo "❌ Could not fetch run details"
    exit 1
fi

STATUS=$(echo "$RUN_INFO" | jq -r '.status')
CONCLUSION=$(echo "$RUN_INFO" | jq -r '.conclusion // "in_progress"')
URL=$(echo "$RUN_INFO" | jq -r '.url')
BRANCH=$(echo "$RUN_INFO" | jq -r '.headBranch')
CREATED=$(echo "$RUN_INFO" | jq -r '.createdAt')

echo "Status: $STATUS"
echo "Conclusion: $CONCLUSION"
echo "Branch: $BRANCH"
echo "Created: $CREATED"
echo "URL: $URL"
echo ""

if [ "$STATUS" = "completed" ]; then
    if [ "$CONCLUSION" = "success" ]; then
        echo "✅ Workflow completed successfully!"
    else
        echo "❌ Workflow failed with conclusion: $CONCLUSION"
    fi
    exit 0
elif [ "$STATUS" = "in_progress" ] || [ "$STATUS" = "queued" ]; then
    echo "⏳ Workflow is $STATUS. Watching for completion..."
    echo ""
    gh run watch "$LATEST_RUN" --exit-status
else
    echo "⚠️  Workflow status: $STATUS"
    exit 1
fi


