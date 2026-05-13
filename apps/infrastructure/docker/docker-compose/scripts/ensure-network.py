#!/usr/bin/env python3
"""Ensure docker networks match the configuration defined in compose files."""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path
from typing import Iterable, List, Set, Tuple


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Inspect docker-compose network definitions, ensure the networks exist, "
            "and verify their drivers, subnets, and internal flags match the composed output."
        )
    )
    parser.add_argument(
        "-f",
        "--compose-file",
        action="append",
        dest="compose_files",
        help="Compose file to inspect (may be specified multiple times). Defaults to docker-compose.yml",
    )
    parser.add_argument(
        "-p",
        "--project-name",
        dest="project_name",
        help="Explicit compose project name passed through to docker compose",
    )
    parser.add_argument(
        "--project-directory",
        dest="project_directory",
        help="Compose project directory passed through to docker compose",
    )
    return parser.parse_args()


def build_compose_args(namespace: argparse.Namespace) -> List[str]:
    args: List[str] = []
    if namespace.project_name:
        args.extend(["-p", namespace.project_name])
    if namespace.project_directory:
        args.extend(["--project-directory", namespace.project_directory])
    return args


def docker_compose_config(compose_args: List[str], compose_file: Path) -> dict:
    if not compose_file.exists():
        raise FileNotFoundError(f"compose file '{compose_file}' not found")

    result = subprocess.run(
        ["docker", "compose", *compose_args, "-f", str(compose_file), "config", "--format", "json"],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(
            "failed to render compose config for '{compose}' with error: {error}".format(
                compose=compose_file, error=result.stderr.strip() or result.stdout.strip()
            )
        )
    return json.loads(result.stdout)


def iter_network_specs(compose_config: dict) -> Iterable[Tuple[str, str, Set[str], bool]]:
    project_name = compose_config.get("name")
    networks = compose_config.get("networks", {})
    for key, value in networks.items():
        if value.get("external"):
            continue

        driver = value.get("driver", "bridge")
        ipam = value.get("ipam", {}) or {}
        subnets: Set[str] = {
            entry.get("subnet")
            for entry in ipam.get("config", []) or []
            if entry.get("subnet")
        }
        internal_flag = bool(value.get("internal", False))
        name = value.get("name")
        if not name:
            name = f"{project_name}_{key}" if project_name else key
        yield name, driver, subnets, internal_flag


def ensure_network(name: str, driver: str, subnets: Set[str], internal: bool) -> None:
    inspect_proc = subprocess.run(
        ["docker", "network", "inspect", name], capture_output=True, text=True
    )

    if inspect_proc.returncode != 0:
        create_cmd = ["docker", "network", "create", "--driver", driver]
        if internal:
            create_cmd.append("--internal")
        for subnet in sorted(subnets):
            create_cmd.extend(["--subnet", subnet])
        create_cmd.append(name)
        print(
            "Creating missing network '{name}' (driver={driver}{subnets}{internal})".format(
                name=name,
                driver=driver,
                subnets=f"; subnets={sorted(subnets)}" if subnets else "",
                internal="; internal=true" if internal else "",
            )
        )
        subprocess.run(create_cmd, check=True)
        return

    network = json.loads(inspect_proc.stdout)[0]
    actual_driver = network.get("Driver")
    actual_internal = bool(network.get("Internal", False))
    actual_subnets = {
        entry.get("Subnet")
        for entry in (network.get("IPAM", {}) or {}).get("Config", []) or []
        if entry.get("Subnet")
    }

    errors: List[str] = []
    if actual_driver != driver:
        errors.append(f"driver={actual_driver} (expected {driver})")
    if subnets and actual_subnets != subnets:
        errors.append(f"subnets={sorted(actual_subnets)} (expected {sorted(subnets)})")
    if internal and not actual_internal:
        errors.append("internal flag is disabled but compose expects internal=true")
    if not internal and actual_internal:
        errors.append("internal flag is enabled but compose expects internal=false")

    if errors:
        print(
            "error: network '{name}' mismatch: {errors}".format(name=name, errors="; ".join(errors)),
            file=sys.stderr,
        )
        print(
            "       You may need to remove the existing network (docker network rm {name})".format(name=name),
            file=sys.stderr,
        )
        raise SystemExit(1)

    print(f"Network '{name}' already matches expected configuration")


def main() -> int:
    namespace = parse_args()
    compose_files = [Path(f) for f in namespace.compose_files] if namespace.compose_files else [Path("docker-compose.yml")]
    compose_args = build_compose_args(namespace)

    for compose_file in compose_files:
        config = docker_compose_config(compose_args, compose_file)
        for name, driver, subnets, internal in iter_network_specs(config):
            ensure_network(name, driver, subnets, internal)

    return 0


if __name__ == "__main__":
    sys.exit(main())

# vim: set ft=python:
