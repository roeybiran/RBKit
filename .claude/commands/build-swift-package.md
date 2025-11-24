# Building a Swift Pacakge

Run:

```bash
swift build -q >/dev/null 2>&1 | grep ': error:'
```

If the script ended with a zero exit code, the build succeeded.