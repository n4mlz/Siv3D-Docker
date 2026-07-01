## Siv3D Template

Minimal Linux-first Siv3D template at the repository root.

### Usage

1. Open the project in your Linux development environment or container.
2. Configure from the repository root.

```bash
cmake -S . -B build -GNinja -DCMAKE_BUILD_TYPE=Debug
```

3. Build the template executable.

```bash
cmake --build build
```

4. Run the graphical smoke test binary.

```bash
./build/Siv3DTemplate
```
