A script to fetch logs from Revtime, send them to prodops, and create a standup post.

Automatically copies the artifact to your clipboard.

To run the script, 2 command-line arguments are required:

- `days_ago`: the number of days in the past from which to fetch logs from Revtime
  - eg. `1` to fetch logs from yesterday
  - eg. `3` on a Monday to fetch logs from Friday
- `today`: what you plan to do today

```
➜  standops git:(main) ✗ mix run lib/standops.exs 4 "Sling some code"
Compiling 1 file (.ex)
Generated standops app
fetched logs from Revtime
creating Prodops Artifact...

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

Copied artifact to clipboard
Artifact ID: 1234
```

You can also refine your standup using the Artifact ID:

```
➜  standops git:(main) ✗ mix run lib/refine.exs 1234 "There is no poker today"
Refining your standup...

Y:
- Paired on Prod deployment and testing
- Merged in work, added new FailureHook test
- Wrapped up #1621
- Paired on #1649
- Discussed features and engineering resources

T:
- Address issues with API
- Continue work on #1649

B:
- None

Copied artifact to clipboard
```
