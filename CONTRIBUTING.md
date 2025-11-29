# Contributing to Abyss KDE Theme

Thank you for considering contributing to Abyss! This document outlines guidelines for contributing.

## Code of Conduct

Be respectful and constructive. We embrace the void, not toxicity.

## How to Contribute

### Reporting Bugs

Before submitting a bug report:
1. Check existing issues to avoid duplicates
2. Test with a fresh Arch Linux + KDE Plasma installation if possible
3. Collect system information:
```bash
   echo "KDE Plasma: $(plasmashell --version)"
   echo "Qt: $(qmake --version)"
   echo "Arch: $(uname -a)"
```

**Bug Report Template:**
```markdown
**Description:**
Brief description of the issue

**Steps to Reproduce:**
1. Step one
2. Step two

**Expected Behavior:**
What should happen

**Actual Behavior:**
What actually happens

**System Information:**
- Plasma version:
- Qt version:
- Arch kernel:

**Logs/Screenshots:**
Attach relevant logs or screenshots
```

### Suggesting Enhancements

Enhancement suggestions are welcome! Please include:
- Clear use case
- How it aligns with "Terminal Purist" philosophy
- Potential implementation approach

### Pull Requests

#### Before Submitting

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Test your changes thoroughly
4. Ensure script remains idempotent
5. Update documentation if needed

#### PR Guidelines

- **Code Style**: Follow existing bash script conventions
- **Commit Messages**: Use clear, descriptive messages
```
  Add: New feature description
  Fix: Bug fix description
  Docs: Documentation update
  Refactor: Code improvement without feature change
```
- **Testing**: Describe testing performed
- **Documentation**: Update relevant docs

#### PR Template
```markdown
**Type of Change:**
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring

**Description:**
What does this PR do?

**Testing:**
How was this tested?

**Checklist:**
- [ ] Script remains idempotent
- [ ] Documentation updated
- [ ] Tested on fresh Plasma installation
- [ ] No breaking changes (or documented if unavoidable)
```

## Development Setup

### Local Testing Environment

1. **Virtual Machine Recommended**:
```bash
   # Using QEMU/KVM
   virt-install --name abyss-test \
     --ram 4096 \
     --disk size=20 \
     --cdrom archlinux.iso
```

2. **Install Minimal Arch + KDE**:
```bash
   pacstrap /mnt base linux linux-firmware plasma kde-applications
```

3. **Clone and Test**:
```bash
   git clone https://github.com/YOUR_USERNAME/abyss-kde-theme.git
   cd abyss-kde-theme
   ./install-abyss.sh
```

### Code Structure
```bash
install-abyss.sh
├── Configuration section (line ~15)
├── Functions (line ~30)
│   ├── install_dependencies()
│   ├── create_directory_structure()
│   ├── generate_ascii_wallpaper()
│   ├── create_plasma_theme()
│   ├── create_gtk_themes()
│   ├── create_lookfeel_package()
│   ├── create_sddm_theme()
│   └── apply_plasma_settings()
└── Main execution (line ~700)
```

### Adding New Features

#### Example: Adding Custom Cursor Theme

1. **Create Function**:
```bash
   create_cursor_theme() {
       log "Creating custom cursor theme..."
       # Implementation
   }
```

2. **Call in Main**:
```bash
   main() {
       # ... existing calls
       create_cursor_theme
       # ...
   }
```

3. **Update Documentation**:
   - Add feature to README.md
   - Document in CONFIGURATION.md

## Documentation Standards

- Use Markdown for all documentation
- Keep language clear and concise
- Include code examples where applicable
- Update README.md for user-facing changes
- Update INSTALL.md for installation changes

## Project Philosophy

Contributions should align with:
- **Minimalism**: Less is more
- **Performance**: Optimize for low resources
- **Purity**: Monochrome aesthetic (no color creep)
- **Terminal-First**: CLI-friendly workflows
- **Transparency**: Users understand what runs on their system

## Areas for Contribution

### Completed
- [x] Kvantum theme integration
- [x] Aurorae window decoration theme
- [x] Plymouth boot theme
- [x] Uninstall script
- [x] Support for different resolutions

### High Priority
- [ ] Automated screenshot generation
- [ ] GRUB boot theme
- [ ] KRunner theme

### Medium Priority
- [ ] Conky configuration
- [ ] System tray icon theme
- [ ] Konsole color scheme export

### Low Priority
- [ ] Animated wallpaper variants
- [ ] Alternative ASCII patterns
- [ ] Cava visualizer config
- [ ] Tmux theme

## Release Process

Maintainers follow this process:

1. Version bump in script comments
2. Update CHANGELOG.md
3. Tag release: `git tag -a v1.x.x -m "Release version 1.x.x"`
4. Push tags: `git push --tags`
5. Create GitHub release with notes

## Questions?

Open an issue with the `question` label or discuss in existing issues.

---

**Thank you for contributing to the void.**