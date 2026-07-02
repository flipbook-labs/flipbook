#!/bin/bash
# Inventory all stories and specs in the workspace
# Usage: bash scripts/inventory-stories.sh (from repo root)
# Outputs a summary of story/spec counts per workspace member

WORKSPACE_ROOT="workspace"

echo ""
echo "=== Flipbook Story & Spec Inventory ==="
echo ""
printf "%-30s %10s %10s\n" "Workspace Member" "Stories" "Specs"
printf '%s\n' "----------------------------------------------------"

total_stories=0
total_specs=0

for member in $WORKSPACE_ROOT/*/; do
	member_name=$(basename "$member")
	story_count=$(find "$member" -name "*.story.luau" 2>/dev/null | wc -l)
	spec_count=$(find "$member" -name "*.spec.luau" 2>/dev/null | wc -l)

	if [ "$story_count" -gt 0 ] || [ "$spec_count" -gt 0 ]; then
		printf "%-30s %10d %10d\n" "$member_name" "$story_count" "$spec_count"
		total_stories=$((total_stories + story_count))
		total_specs=$((total_specs + spec_count))
	fi
done

printf '%s\n' "----------------------------------------------------"
printf "%-30s %10d %10d\n" "TOTAL" "$total_stories" "$total_specs"
echo ""
