# AGENTS.md - Development Guide

This is a collection of docker-compose definitions for homelab services. They are nearly all of the same form, being a service container and a sidecar container that provides networking.

The `sidecar` directory is the build for that sidecar.

When a container image needs to be built, that's done via the GitHub action in container-build.yml

The purpose of this project is to have a series of self-hosted applications that are exclusively accessible on my tailscale network, running on one of three different hosts in my network (prime, blob, and bitbucket)

## Build Commands

- These only apply in directories that have a Dockerfile
- `docker build .` to build

## Code Style Guidelines

- compose files should be as minimal as possible, but not terse to the point of inscrutability
- prefer compose patterns that are common to all of these, but exceptions are allowed
- make sure the code you generate will be accepted by the pre-commit hooks configured in .pre-commit-config.yaml

## Interactions

Most of these compose definitions are not intended to be invoked on the development host; that's okay. They'll be iterated on at the destination. Claude's job here is to save my time typing out and refactoring. I'll test things myself.

## Repository Workflow

- If the repository organization is "github" my changes don't need to be worked on in forks, they can be done in feature branches.
- When creating a feature branch, use naming as follows:
  - make the feature branch a kebab-case short description of the feature
  - if the organization is github, prefix the branch name with "o1-"

## Repository Permissions and Actions

- Unless explicity instructed, do not auto-close related issues.
- Unless explicitly instructed, do not auto-merge pull requests.
- Unless explicitly told to, do not push code.

## Code Exploration and Reference

- When asked where something is defined, always include the code locations of function definitions and key assignments, specifying the exact file and path.

## Python Project Management

- In python projects, prefer using uv and hatchling for dependencies and builds respectively. Use instructions from https://docs.astral.sh/uv/concepts/projects/dependencies/ to manage dependencies.
- Verify any change to pyproject.toml using "uv sync" and fix those issues as you go.
- Never introduce a dependency on Poetry or Pipenv to a project, but don't remove them unless I explicitly ask.

## Build and Task Management

- Prefer justfiles for storing repeated build instructions.
- If no default task already exists, a default task that lists the tasks with docs should be created.

## Code Style and Linting Guidelines

### Python Code Guidelines
- Maintain `ruff` format style
- Prefer more modern library choices:
  - Use `pathlib` over `os`
  - Use `httpx` over `requests`

### Ruby Code Guidelines
- Attempt to approximate the rubocop style, but don't run rubocop itself to do it

### Go Code Guidelines
- Identify the main CLI entry point if possible
- Ensure code always compiles after changes
- Use golangci-lint to lint the code
- Allow auto-fixes from linting tools

## Pre-Commit Configuration

- In general, if you observe a .pre-commit-config.yaml file, try to keep the code you generate in a shape that will pass those. Either use the tools themselves, or imitate them as best you can.

## Version Control Systems

- If a .jj file exists in the repository, it is using jujutsu as a version control system. At the end of a series of operations, describe what you did by running `jj describe -m` to add a new commit message.
