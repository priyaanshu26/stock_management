# Contributing to Stock Management System

First off, thank you for considering contributing to Stock Management System! It's people like you that make this project better for everyone.

## Code of Conduct

By participating in this project, you are expected to uphold our Code of Conduct. Please report unacceptable behavior to [priyanshu.171561@gmail.com].

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the issue list as you might find that you don't need to create one. When you are creating a bug report, please include as many details as possible:

* **Use a clear and descriptive title**
* **Describe the exact steps to reproduce the problem**
* **Provide specific examples to demonstrate the steps**
* **Describe the behavior you observed and what behavior you expected**
* **Include screenshots if applicable**
* **Include your environment details** (Flutter version, device, OS, etc.)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

* **Use a clear and descriptive title**
* **Provide a step-by-step description of the suggested enhancement**
* **Provide specific examples to demonstrate the steps**
* **Describe the current behavior and explain the behavior you expected**
* **Explain why this enhancement would be useful**

### Pull Requests

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Make your changes
4. Make sure your code follows the project's style guidelines
7. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
8. Push to the branch (`git push origin feature/AmazingFeature`)
9. Open a Pull Request

## Development Setup

1. **Install Flutter** - Follow the [official Flutter installation guide](https://flutter.dev/docs/get-started/install)

2. **Clone your fork**
   ```bash
   git clone https://github.com/your-username/stock_management.git
   cd stock_management
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Set up Firebase** - Follow the setup instructions in the README

5. **Run the app**
   ```bash
   flutter run
   ```

## Style Guidelines

### Dart Code Style

* Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
* Use `flutter format` to format your code
* Run `flutter analyze` to check for issues

### Commit Messages

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally after the first line

### File Structure

When adding new files, please follow the existing structure:

```
lib/
├── models/           # Data models
├── providers/        # State management
├── screens/          # UI screens
├── services/         # Business logic
└── widgets/          # Reusable UI components
```

## Testing

* Test your changes on multiple devices/screen sizes
* Ensure the app works correctly across different scenarios
* Verify your changes don't break existing functionality

## Documentation

* Update README.md if you change functionality
* Add inline comments for complex logic
* Update API documentation if you change interfaces
* Add examples for new features

## Questions?

Don't hesitate to ask questions! You can:

* Open an issue with the "question" label
* Reach out via email
* Start a discussion in the repository

## Recognition

Contributors will be recognized in:

* README.md acknowledgments section
* Release notes for significant contributions
* Project documentation

Thank you for contributing! 🎉
