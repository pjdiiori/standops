A script to fetch logs from Revtime, send them to prodops, and create a standup post.
Automatically copies the artifact to your clipboard.

```sh
➜  standops git:(main) ✗ mix run lib/standops.exs 4 "Sling some code"
Compiling 1 file (.ex)
Generated standops app
fetched logs from Revtime
creating Prodops Artifact...
Copied artifact to clipboard
Y:
- Paired on Prod deployment and testing
- Merged in work, added new FailureHook test
- Wrapped up #1621
- Paired on #1649
- Discussed features and engineering resources

T:
- Address issues with API
- Continue work on #1649
- Poker planning session

B:
- None
```
