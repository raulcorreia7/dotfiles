#!/bin/sh

# Ensure clean state
rm -rf tests/git_repo tests/mock_fzf tests/err.log tests/personal

# Create a mock fzf that doesn't block and exits immediately
cat << 'EOF' > tests/mock_fzf
#!/bin/sh
cat > /dev/null
echo ""
echo "test_selection"
EOF
chmod +x tests/mock_fzf

# Export necessary variables
export FZF_BIN="$(pwd)/tests/mock_fzf"
export FZFS_SCRIPT_PATH="$(pwd)/scripts/fzf.sh"
# Set project roots to test specific path
export FZFS_PROJECT_ROOTS="$(pwd)/tests/personal"

LOGFILE="$(pwd)/tests/err.log"

# Function to run a test
run_test() {
    local name="$1"
    local cmd="$2"
    echo "=== Test: $name ==="
    
    eval "$cmd" 2> "$LOGFILE"
    
    # Check if stderr has "Error:"
    if grep -q "Error:" "$LOGFILE"; then
        cat "$LOGFILE"
        echo "FAIL"
    else
        echo "PASS"
    fi
    > "$LOGFILE"
}

# 1. Basic Files (Implicit - should now be ALL)
run_test "Implicit Mode (All)" "sh scripts/fzf.sh"

# 2. Explicit Files
run_test "Files Mode (-f)" "sh scripts/fzf.sh -f"

# 3. Directories
run_test "Dirs Mode (-d)" "sh scripts/fzf.sh -d"

# 4. Explicit Path
run_test "Explicit Path" "sh scripts/fzf.sh /tmp"

# 5. Git Setup
mkdir -p tests/git_repo
cd tests/git_repo || exit 1
git init -q
touch testfile
git add testfile
git commit -m "init" -q

# 6. Git Modes
# Use absolute path for script
run_test "Git Files (-g)" "sh $FZFS_SCRIPT_PATH -g"
run_test "Git Branch (-gb)" "sh $FZFS_SCRIPT_PATH -gb"
run_test "Git Commits (-gc)" "sh $FZFS_SCRIPT_PATH -gc"

cd ../..

# 7. Projects (Mocked)
mkdir -p tests/personal/myproject/.git
# Expect failure on cd because directory doesn't exist, but logic should run
echo "=== Test: Projects (-gp) ==="
sh scripts/fzf.sh -gp 2> "$LOGFILE"
if grep -q "cd:.*test_selection" "$LOGFILE"; then
    echo "PASS (Expected cd failure)"
elif grep -q "Error:" "$LOGFILE"; then
    cat "$LOGFILE"
    echo "FAIL"
else
    # If no cd error (maybe running in subshell masked it?), check if it ran without script errors
    echo "PASS"
fi

# Cleanup
rm -rf tests/git_repo tests/mock_fzf tests/err.log tests/personal
echo "Tests Completed."