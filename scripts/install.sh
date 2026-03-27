#!/bin/bash
# YWIMC - Your Wish Is My Command
# Universal installer for agents, skills, and instructions
# Supports: Claude Code, OpenCode, Cursor, Windsurf, Copilot, Gemini CLI, Aider

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
AGENTS_DIR="$PROJECT_DIR/agents"
SKILLS_DIR="$PROJECT_DIR/skills"
INSTRUCTIONS_DIR="$PROJECT_DIR/instructions"
CONFIGS_DIR="$PROJECT_DIR/configs"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║   YWIMC - Your Wish Is My Command                  ║${NC}"
    echo -e "${CYAN}║   Universal AI Agent & Skill Installer              ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
}

count_agents() {
    find "$AGENTS_DIR" -name "*.md" -not -name "README.md" -not -name "CONTRIBUTING.md" | wc -l | tr -d ' '
}

count_skills() {
    find "$SKILLS_DIR" -name "SKILL.md" -o -name "skill.md" 2>/dev/null | wc -l | tr -d ' '
}

install_claude_code() {
    echo -e "${BLUE}Installing for Claude Code...${NC}"

    # Agents
    mkdir -p ~/.claude/agents
    find "$AGENTS_DIR" -name "*.md" -not -name "README.md" -not -name "CONTRIBUTING.md" -exec cp {} ~/.claude/agents/ \;
    local agent_count=$(ls ~/.claude/agents/*.md 2>/dev/null | wc -l | tr -d ' ')
    echo -e "  ${GREEN}$agent_count agents${NC} -> ~/.claude/agents/"

    # Skills
    mkdir -p ~/.claude/skills
    for skill_dir in "$SKILLS_DIR"/*/; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            cp -r "$skill_dir" ~/.claude/skills/
        fi
    done
    local skill_count=$(count_skills)
    echo -e "  ${GREEN}$skill_count skills${NC} -> ~/.claude/skills/"

    echo -e "  ${GREEN}Done!${NC} Scope: Global (all projects)"
}

install_opencode() {
    echo -e "${BLUE}Installing for OpenCode...${NC}"

    # Agents
    mkdir -p ~/.config/opencode/agents
    find "$AGENTS_DIR" -name "*.md" -not -name "README.md" -not -name "CONTRIBUTING.md" -exec cp {} ~/.config/opencode/agents/ \;
    local agent_count=$(ls ~/.config/opencode/agents/*.md 2>/dev/null | wc -l | tr -d ' ')
    echo -e "  ${GREEN}$agent_count agents${NC} -> ~/.config/opencode/agents/"

    # Config template
    if [ -f "$CONFIGS_DIR/opencode.json" ]; then
        echo -e "  ${YELLOW}Config template${NC} available at: $CONFIGS_DIR/opencode.json"
        echo -e "  ${YELLOW}Copy with:${NC} cp $CONFIGS_DIR/opencode.json ~/.config/opencode/opencode.json"
    fi

    echo -e "  ${GREEN}Done!${NC} Scope: Global (all projects)"
}

install_cursor() {
    echo -e "${BLUE}Installing for Cursor...${NC}"

    if [ -z "$1" ]; then
        echo -e "  ${YELLOW}Cursor requires a project directory.${NC}"
        echo -e "  ${YELLOW}Usage:${NC} $0 cursor /path/to/project"
        return 1
    fi

    local project_dir="$1"
    mkdir -p "$project_dir/.cursor/rules"
    find "$AGENTS_DIR" -name "*.md" -not -name "README.md" -not -name "CONTRIBUTING.md" -exec sh -c '
        name=$(basename "$1" .md)
        cp "$1" "'"$project_dir"'/.cursor/rules/${name}.mdc"
    ' _ {} \;
    local count=$(ls "$project_dir/.cursor/rules/"*.mdc 2>/dev/null | wc -l | tr -d ' ')
    echo -e "  ${GREEN}$count agents${NC} -> $project_dir/.cursor/rules/"
    echo -e "  ${GREEN}Done!${NC} Scope: Project ($project_dir)"
}

install_copilot() {
    echo -e "${BLUE}Installing for GitHub Copilot...${NC}"

    mkdir -p ~/.github/agents
    find "$AGENTS_DIR" -name "*.md" -not -name "README.md" -not -name "CONTRIBUTING.md" -exec cp {} ~/.github/agents/ \;
    local agent_count=$(ls ~/.github/agents/*.md 2>/dev/null | wc -l | tr -d ' ')
    echo -e "  ${GREEN}$agent_count agents${NC} -> ~/.github/agents/"
    echo -e "  ${GREEN}Done!${NC} Scope: Global (all projects)"
}

install_windsurf() {
    echo -e "${BLUE}Installing for Windsurf...${NC}"

    if [ -z "$1" ]; then
        echo -e "  ${YELLOW}Windsurf requires a project directory.${NC}"
        echo -e "  ${YELLOW}Usage:${NC} $0 windsurf /path/to/project"
        return 1
    fi

    local project_dir="$1"
    echo "# YWIMC Agents - Auto-generated" > "$project_dir/.windsurfrules"
    echo "" >> "$project_dir/.windsurfrules"
    find "$AGENTS_DIR" -name "*.md" -not -name "README.md" -not -name "CONTRIBUTING.md" -exec sh -c '
        echo "## $(basename "$1" .md)"
        echo ""
        cat "$1"
        echo ""
        echo "---"
        echo ""
    ' _ {} \; >> "$project_dir/.windsurfrules"
    echo -e "  ${GREEN}Agents consolidated${NC} -> $project_dir/.windsurfrules"
    echo -e "  ${GREEN}Done!${NC} Scope: Project ($project_dir)"
}

install_gemini() {
    echo -e "${BLUE}Installing for Gemini CLI...${NC}"

    mkdir -p ~/.gemini/extensions/ywimc-agents
    find "$AGENTS_DIR" -name "*.md" -not -name "README.md" -not -name "CONTRIBUTING.md" -exec cp {} ~/.gemini/extensions/ywimc-agents/ \;
    local agent_count=$(ls ~/.gemini/extensions/ywimc-agents/*.md 2>/dev/null | wc -l | tr -d ' ')
    echo -e "  ${GREEN}$agent_count agents${NC} -> ~/.gemini/extensions/ywimc-agents/"
    echo -e "  ${GREEN}Done!${NC} Scope: Global (all projects)"
}

install_all_global() {
    echo -e "${CYAN}Installing for ALL global tools...${NC}"
    echo ""
    install_claude_code
    echo ""
    install_opencode
    echo ""
    install_copilot
    echo ""
    install_gemini
    echo ""
    echo -e "${GREEN}All global installations complete!${NC}"
    echo -e "${YELLOW}Note:${NC} Cursor and Windsurf are project-scoped. Run separately per project."
}

show_status() {
    echo -e "${CYAN}YWIMC Status:${NC}"
    echo -e "  Agents: $(count_agents) files across $(ls -d "$AGENTS_DIR"/*/ 2>/dev/null | wc -l | tr -d ' ') categories"
    echo -e "  Skills: $(count_skills) skills"
    echo ""
    echo -e "${CYAN}Installed to:${NC}"
    [ -d ~/.claude/agents ] && echo -e "  ${GREEN}Claude Code${NC}: $(ls ~/.claude/agents/*.md 2>/dev/null | wc -l | tr -d ' ') agents" || echo -e "  ${RED}Claude Code${NC}: not installed"
    [ -d ~/.config/opencode/agents ] && echo -e "  ${GREEN}OpenCode${NC}: $(ls ~/.config/opencode/agents/*.md 2>/dev/null | wc -l | tr -d ' ') agents" || echo -e "  ${RED}OpenCode${NC}: not installed"
    [ -d ~/.github/agents ] && echo -e "  ${GREEN}Copilot${NC}: $(ls ~/.github/agents/*.md 2>/dev/null | wc -l | tr -d ' ') agents" || echo -e "  ${RED}Copilot${NC}: not installed"
    [ -d ~/.gemini/extensions/ywimc-agents ] && echo -e "  ${GREEN}Gemini CLI${NC}: $(ls ~/.gemini/extensions/ywimc-agents/*.md 2>/dev/null | wc -l | tr -d ' ') agents" || echo -e "  ${RED}Gemini CLI${NC}: not installed"
    [ -d ~/.claude/skills ] && echo -e "  ${GREEN}Skills${NC}: $(ls -d ~/.claude/skills/*/ 2>/dev/null | wc -l | tr -d ' ') skills in Claude Code" || echo -e "  ${RED}Skills${NC}: not installed"
}

print_header

case "${1:-}" in
    claude-code|claude)
        install_claude_code
        ;;
    opencode)
        install_opencode
        ;;
    cursor)
        install_cursor "$2"
        ;;
    copilot)
        install_copilot
        ;;
    windsurf)
        install_windsurf "$2"
        ;;
    gemini|gemini-cli)
        install_gemini
        ;;
    all)
        install_all_global
        ;;
    status)
        show_status
        ;;
    *)
        echo "Usage: $0 <tool> [project-dir]"
        echo ""
        echo "Global tools (no project dir needed):"
        echo "  claude-code   Install to ~/.claude/agents/ + ~/.claude/skills/"
        echo "  opencode      Install to ~/.config/opencode/agents/"
        echo "  copilot       Install to ~/.github/agents/"
        echo "  gemini-cli    Install to ~/.gemini/extensions/"
        echo "  all           Install to all global tools at once"
        echo ""
        echo "Project-scoped tools (require project dir):"
        echo "  cursor <dir>      Install to <dir>/.cursor/rules/"
        echo "  windsurf <dir>    Install to <dir>/.windsurfrules"
        echo ""
        echo "Other:"
        echo "  status        Show installation status"
        echo ""
        echo "Examples:"
        echo "  $0 all                          # Install everywhere"
        echo "  $0 claude-code                  # Claude Code only"
        echo "  $0 cursor ~/projects/my-app     # Cursor for specific project"
        ;;
esac
