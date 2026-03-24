# MyDock

MyDock is a lightweight, Bash-based orchestration framework for managing Dockerized application environments.

It provides a consistent CLI, shared lifecycle commands, and reusable infrastructure primitives for defining and operating containerized projects across local development and simpler real-world deployments.

---

## Why MyDock Exists

Docker-based workflows often become fragmented:

- every project defines its own structure and conventions  
- environment setup is inconsistent  
- switching between projects is slow and error-prone  
- shared concerns (proxying, hosts, tooling) are duplicated  

MyDock standardizes this by introducing a layered system that separates:

- control (CLI + commands)  
- shared infrastructure behavior  
- project definitions  
- environment-specific configuration  

---

## Architecture

MyDock is organized into layered components:

- `bin/mydock`  
  The main CLI entrypoint. Validates commands and projects, loads shared runtime helpers, initializes project-scoped environment state, and dispatches lifecycle commands.

- `bin/commands/`  
  Shared lifecycle commands (`build`, `start`, `stop`, `push`) that provide a consistent interface while delegating stack-specific behavior to each project definition.

- `bin/inc/`  
  Reusable infrastructure primitives shared across all projects, including environment persistence, reverse proxy management, hosts file updates, working copy handling, and utility services such as Adminer.

- `projects/`  
  Public project definitions and stack templates. Each project encapsulates its own `docker-compose.yml`, Dockerfiles, and lifecycle scripts.

- `projects/custom/`  
  Git-ignored private project definitions used for real environments. This separation allows the orchestration framework to remain reusable and version-controlled while keeping project-specific implementations private.

- `utilities/`  
  Shared supporting services such as the reverse proxy and Adminer, used across multiple project environments.

---

### High-Level Flow

```
mydock CLI
   ↓
command layer (bin/commands)
   ↓
shared primitives (bin/inc)
   ↓
project definitions (projects/* or projects/custom/*)
   ↓
docker-compose + containers
```

---

## Usage

MyDock provides a consistent CLI for managing project environments.

### List available projects

```bash
ls projects/
```

Example:

```
apache/
apache-php7/
apache-php8/
laravel10-app-dev/
node/
redis/
```

---

### Start an environment

```bash
./bin/mydock start laravel10-app-dev
```

---

### Stop an environment

```bash
./bin/mydock stop laravel10-app-dev
```

---

### Build containers

```bash
./bin/mydock build laravel10-app-dev
```

---

### Add a new project

Create a new directory under `projects/` or `projects/custom/` with:

- `docker-compose.yml`
- optional lifecycle scripts (`start.sh`, `stop.sh`, `build.sh`)

Then run:

```bash
./bin/mydock start <your-project>
```

---

## CLI Behavior

MyDock is designed to be self-discoverable and safe by default.

### Command discovery

Running `mydock` without arguments shows available commands:

```bash
mydock
```

---

### Project discovery

Running a command without a project lists available environments:

```bash
mydock start
```

Projects are discovered dynamically from:

- `projects/`
- `projects/custom/`

---

### Safe defaults with optional depth

Basic commands operate with safe defaults:

```bash
mydock stop my-project
```

Stops containers only.

Some project-specific stop scripts also support deeper cleanup:

```bash
mydock stop my-project -civ
```

Where supported:

- `-c` remove containers  
- `-i` remove images  
- `-v` remove volumes  

This allows developers to choose between quick iteration and full teardown when needed.

---

## Real-World Usage

MyDock was designed to standardize Docker-based environments across multiple projects, not just as a single-project tool.

In practice, it has been used to:

- provide a unified CLI for managing multiple application stacks  
- persist project-specific configuration outside project definitions  
- centralize shared infrastructure concerns like proxying and host routing  
- support private, project-specific environments outside version control  
- manage both local development environments and simpler production-style LAMP deployments  

This repository contains the reusable framework and public stack definitions.  
Project-specific implementations under `projects/custom/` are intentionally excluded.

---

## What This Is (and Isn’t)

**This is:**

- a lightweight orchestration layer for Docker environments  
- a developer-focused system for managing environment lifecycle  
- a reusable framework for multi-project workflows  

**This is not:**

- a replacement for Kubernetes  
- a full production orchestration platform  
- a heavy abstraction layer  

---

## Optional Setup

For convenience, MyDock can be added to your shell PATH:

```bash
ln -s /path/to/mydock/bin/mydock /usr/local/bin/mydock
```

This allows usage like:

```bash
mydock start my-project
```

---

### Docker permissions

To avoid running Docker commands as root:

```bash
sudo usermod -aG docker $USER
```

In some setups, MyDock may be run under a dedicated user (e.g., `mydock`) assigned to the `docker` group, with environments located under:

```
/home/mydock/<project>
```

---

## Design Goals

- **Consistency** - unified lifecycle across projects  
- **Modularity** - reusable infrastructure primitives  
- **Simplicity** - minimal abstraction, easy to debug  
- **Extensibility** - pluggable project definitions  
- **Developer Experience** - fast, predictable workflows  

---

## Why It Matters

Developers spend too much time managing environments instead of building software.

MyDock is an attempt to reduce that friction by:

- standardizing workflows  
- reducing duplication  
- making environments predictable and reusable  

---

## Future Improvements

- improved CLI ergonomics  
- project scaffolding/templates  
- enhanced documentation and onboarding  
- optional service discovery improvements
