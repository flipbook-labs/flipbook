#!/bin/bash
# Detect environment variable drift in Flipbook source
# Usage: bash scripts/detect-env-drift.sh (from repo root)
# Compares process.env reads in code against .env.template

echo ""
echo "=== Environment Variable Drift Detection ==="
echo ""

# Get vars from .env.template
declared_vars=$(grep '^[A-Z_][A-Z0-9_]*=' .env.template 2>/dev/null | cut -d= -f1 | sort)

# Get vars used in code (process.env.VAR_NAME pattern)
used_vars=$(grep -r 'process\.env\.[A-Z_][A-Z0-9_]*' workspace .lute 2>/dev/null \
	| grep -o 'process\.env\.[A-Z_][A-Z0-9_]*' \
	| cut -d. -f3 \
	| sort | uniq -c | sort -rn)

# Find undeclared vars (used but not in template)
echo "⚠️  UNDECLARED (used in code but not in .env.template):"
echo ""
undeclared_count=0
while read -r count var; do
	found=0
	for decl in $declared_vars; do
		if [ "$var" = "$decl" ]; then
			found=1
			break
		fi
	done
	if [ "$found" = "0" ]; then
		echo "  $var (used $count times)"
		undeclared_count=$((undeclared_count + 1))
	fi
done <<< "$used_vars"

if [ "$undeclared_count" = "0" ]; then
	echo "  (none)"
fi
echo ""

# Find unused vars (declared but never used)
echo "ℹ️  UNUSED (in .env.template but never read in code):"
echo ""
unused_count=0
for var in $declared_vars; do
	found=0
	while read -r count used_var; do
		if [ "$var" = "$used_var" ]; then
			found=1
			break
		fi
	done <<< "$used_vars"
	if [ "$found" = "0" ]; then
		echo "  $var"
		unused_count=$((unused_count + 1))
	fi
done

if [ "$unused_count" = "0" ]; then
	echo "  (none)"
fi
echo ""

# Summary
declared_count=$(echo "$declared_vars" | wc -l)
used_count=$(echo "$used_vars" | wc -l)

echo "Summary: $declared_count env vars declared, $used_count vars read from code"
if [ "$undeclared_count" -gt 0 ] || [ "$unused_count" -gt 0 ]; then
	echo "❌ Drift detected"
	echo ""
else
	echo "✅ No drift"
	echo ""
fi
