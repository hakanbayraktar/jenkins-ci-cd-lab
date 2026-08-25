# Instructor guide

Start with `make doctor && make up`; the first run downloads images and Jenkins plugins. Demonstrate Job DSL-created jobs, JCasC credentials, DIND isolation, immutable `BUILD-SHA` tags, and Nexus artifact browsing. Use the two exercises in the student guide and have students use Jenkins console logs plus `make logs`, `kubectl describe`, and `kubectl get events -A --sort-by=.lastTimestamp` to diagnose them. End with `make down`; use `make reset` only when a clean lab is required.
