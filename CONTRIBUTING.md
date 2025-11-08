# Contributing Guide

Thank you for your interest in contributing to TasoSky! 🎉

This file contains information about how you can contribute to the project.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Process](#development-process)
- [Code Style](#code-style)
- [Commit Messages](#commit-messages)
- [Pull Request Process](#pull-request-process)

## 🤝 Code of Conduct

This project is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to abide by these rules.

## 💡 How Can I Contribute?

### Reporting Bugs

1. **Check existing issues** - Your issue may already be reported
2. **Create a new issue** - Add a descriptive title and detailed description
3. **Add screenshots** - If possible, add images showing the problem
4. **List steps** - Add steps to reproduce the issue

### Suggesting Features

1. **Create a new issue** - With "Feature Request" label
2. **Describe the feature** - Explain what you want to do in detail
3. **Add usage scenario** - Explain how the feature will be used
4. **Design suggestions** - Share your design ideas if you have any

### Code Contribution

1. **Comment on the issue** - Add a comment to the issue you want to work on
2. **Fork the repository** - Fork the repository
3. **Create a branch** - Create a new feature branch
4. **Write code** - Make your changes
5. **Test** - Test your changes
6. **Submit Pull Request** - Open a PR and explain your changes

## 🔧 Development Process

### 1. Fork the Repository

Fork the repository on GitHub.

### 2. Clone the Repository

```bash
git clone https://github.com/yourusername/TasoSky.git
cd TasoSky
```

### 3. Add Remote

```bash
git remote add upstream https://github.com/tahsinmert/TasoSky.git
```

### 4. Create Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

### 5. Make Your Changes

- Write code
- Test
- Update documentation (if needed)

### 6. Commit

```bash
git add .
git commit -m "feat: new feature added"
```

### 7. Push

```bash
git push origin feature/your-feature-name
```

### 8. Create Pull Request

Create a Pull Request on GitHub and explain your changes.

## 📝 Code Style

### Swift Style Guide

- **Naming**: Use camelCase
- **Indentation**: 4 spaces (not tabs)
- **Line Length**: Try not to exceed 100 characters if possible
- **Comments**: Add descriptive comments for complex logic

### Example

```swift
// ✅ Good
struct PlanetDetailView: View {
    let planet: Planet
    @State private var selectedTab: Int = 0
    
    var body: some View {
        // ...
    }
}

// ❌ Bad
struct planetDetailView:View{
let planet:Planet
@State private var selectedTab:Int=0
var body:some View{//...}
}
```

### File Organization

- Each file should have a single responsibility
- Related files should be in the same folder
- File names should be descriptive

## 💬 Commit Messages

### Format

```
<type>: <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation change
- `style`: Code formatting (functionality unchanged)
- `refactor`: Code refactoring
- `test`: Test addition/fix
- `chore`: Build process or helper tools

### Examples

```bash
feat: parallax scrolling added to planet detail page

fix: asteroid filtering bug fixed

docs: installation steps added to README

style: code formatting adjusted
```

## 🔍 Pull Request Process

### PR Checklist

- [ ] Code works and is tested
- [ ] Tests added for new features
- [ ] Documentation updated
- [ ] Code style rules followed
- [ ] Commit messages are descriptive
- [ ] Breaking changes are mentioned if any

### PR Description

In your PR description, specify:

1. **What was done?** - Summary of changes made
2. **Why was it done?** - Justification for the change
3. **How was it tested?** - Test steps
4. **Screenshots** - If there are UI changes

### Review Process

1. **Automatic checks** - CI/CD checks must pass
2. **Code review** - At least one maintainer must review
3. **Changes** - Changes may be requested if needed
4. **Approval** - After review approval, it will be merged

## 🐛 Bug Reporting

### When Reporting Bugs

1. **Title**: Short and descriptive
2. **Description**: Describe the problem in detail
3. **Steps**: Steps to reproduce the problem
4. **Expected**: What should happen
5. **Actual**: What actually happened
6. **Screenshots**: Add if available
7. **Device/Info**: iOS version, device model

### Example

```markdown
**Title**: Parallax scroll not working on planet detail page

**Description**: 
When scrolling on the planet detail page, parallax effect is not visible.

**Steps**:
1. Go to Planets tab
2. Tap on a planet
3. Scroll on the detail page

**Expected**: Parallax effect should be visible
**Actual**: No effect at all

**Device**: iPhone 15 Pro, iOS 26.0
```

## 📚 Documentation

- Add documentation for new features
- Update README
- Add code comments (if needed)

## ❓ Questions?

If you have any questions:

- Open an issue
- Ask in Discussions
- Send an email

## 🙏 Thank You

Thank you for your contributions! Every contribution makes the project better. 🚀

---

**Note**: This guide is constantly updated. Please share your suggestions!
