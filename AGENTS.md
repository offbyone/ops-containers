# CLAUDE.md - Development Guide

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
