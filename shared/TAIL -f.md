## What does `tail -f /dev/null` do?

This is a common Docker anti-pattern used to keep a container running without doing anything useful.

- `tail -f` = "follow" a file — it waits for new lines to appear at the end.
- `/dev/null` = a special file that discards everything written to it and always appears empty.

It means: "Sit here forever waiting for new lines from a file that will never change."

In development or bad Docker setups, people use it to keep the container alive, like this:

`CMD ["sh", "-c", "some-command & tail -f /dev/null"]`

The actual service (`some-command`) runs in the background, and `tail -f /dev/null` keeps the container alive artificially.
Why this is bad:

- The main process becomes tail, not your actual service.
- Docker doesn't track your service properly.
- You lose logging, exit codes, and clean shutdown behavior.

Running a process in the background can be useful when you want a task to run in parallel with other commands in a script — instead of blocking execution. You background a process because:
- You want to start it, but don't wait for it to finish
- You need to do other things at the same time

Example: Backgrounding a server while setting up something else
```bash
#!/bin/bash

# Start a local HTTP server in the background
python3 -m http.server 8000 &

# Do something else while the server is running
echo "Fetching data..."
curl http://localhost:8000/myfile.txt
```

- `python3 -m http.server` starts a server **in the background**.
- Your script can continue to fetch from that server **immediately**, without waiting for the server to exit.

But in a Docker container, **PID 1 is crucial**. If you run your main process (e.g., a server) in the background, the container might exit immediately because it thinks it's done.

That's why, in Docker:
- Temporary backgrounding is fine if it's followed by a proper foreground process.
- But `tail -f /dev/null` is a **dummy foreground process**, a hack that fakes activity just to keep the container alive, which is discouraged.