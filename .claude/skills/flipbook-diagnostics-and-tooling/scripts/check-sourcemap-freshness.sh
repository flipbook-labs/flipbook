#!/bin/bash
# Check if sourcemaps are fresh relative to source files
# Usage: bash scripts/check-sourcemap-freshness.sh (from repo root)
# Verifies sourcemaps were generated after the latest source file modification

echo ""
echo "=== Sourcemap Freshness Check ==="
echo ""

all_fresh=true

# Check workspace/flipbook-core sourcemap
if [ -f "workspace/flipbook-core/sourcemap.json" ]; then
	sourcemap_time=$(stat -f %m "workspace/flipbook-core/sourcemap.json" 2>/dev/null || stat -c %Y "workspace/flipbook-core/sourcemap.json" 2>/dev/null)
	latest_source_time=$(find workspace/flipbook-core/src -name "*.luau" -type f -exec stat -f %m {} \; 2>/dev/null | sort -n | tail -1 || find workspace/flipbook-core/src -name "*.luau" -type f -exec stat -c %Y {} \; 2>/dev/null | sort -n | tail -1)

	if [ -z "$sourcemap_time" ] || [ -z "$latest_source_time" ]; then
		echo "⚠️  workspace/flipbook-core: cannot determine file times"
	elif [ "$sourcemap_time" -ge "$latest_source_time" ]; then
		echo "✅ workspace/flipbook-core: sourcemap is fresh"
	else
		echo "❌ workspace/flipbook-core: sourcemap older than source"
		all_fresh=false
	fi
else
	echo "⚠️  workspace/flipbook-core: sourcemap not found"
fi

# Check root sourcemap
if [ -f "sourcemap.json" ]; then
	sourcemap_time=$(stat -f %m "sourcemap.json" 2>/dev/null || stat -c %Y "sourcemap.json" 2>/dev/null)
	latest_source_time=$(find workspace -name "*.luau" -type f ! -path "*/build/*" -exec stat -f %m {} \; 2>/dev/null | sort -n | tail -1 || find workspace -name "*.luau" -type f ! -path "*/build/*" -exec stat -c %Y {} \; 2>/dev/null | sort -n | tail -1)

	if [ -z "$sourcemap_time" ] || [ -z "$latest_source_time" ]; then
		echo "⚠️  root project: cannot determine file times"
	elif [ "$sourcemap_time" -ge "$latest_source_time" ]; then
		echo "✅ root project: sourcemap is fresh"
	else
		echo "❌ root project: sourcemap older than source"
		all_fresh=false
	fi
else
	echo "⚠️  root project: sourcemap not found"
fi

echo ""
if [ "$all_fresh" = true ]; then
	echo "✅ All sourcemaps are fresh"
	echo ""
else
	echo "⚠️  Some sourcemaps may be stale — rebuild with: lute run build --clean"
	echo ""
fi
