"""Write the semantic-release version into the repository VERSION file."""

from pathlib import Path
import sys


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: python publish/bump_version.py <version>", file=sys.stderr)
        return 1

    version = sys.argv[1].strip()
    if not version:
        print("Version must not be empty.", file=sys.stderr)
        return 1

    root_dir = Path(__file__).resolve().parents[1]
    version_file = root_dir / "VERSION"
    version_file.write_text(f"{version}\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
