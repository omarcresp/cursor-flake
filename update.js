import { execFileSync } from "child_process";
import { readFileSync, writeFileSync } from "fs";

const DOWNLOAD_API =
  "https://api2.cursor.sh/updates/api/download/stable";
const SOURCES_FILE = "sources.json";
const TARGETS = {
  "x86_64-linux": "linux-x64",
  "aarch64-darwin": "darwin-arm64",
};

async function getLatestRelease() {
  const releases = await Promise.all(
    Object.entries(TARGETS).map(async ([system, apiTarget]) => {
      const response = await fetch(`${DOWNLOAD_API}/${apiTarget}/cursor`, {
        headers: {
          "User-Agent": "Cursor-Version-Checker",
          "Cache-Control": "no-cache",
        },
      });

      if (!response.ok) {
        throw new Error(
          `Cursor API returned ${response.status} for ${system}`
        );
      }

      const release = await response.json();
      if (!release.version || !release.downloadUrl) {
        throw new Error(`Cursor API returned invalid metadata for ${system}`);
      }

      return [system, release];
    })
  );

  const versions = new Set(releases.map(([, release]) => release.version));
  if (versions.size !== 1) {
    throw new Error(
      `Cursor platforms are on different versions: ${[...versions].join(", ")}`
    );
  }

  return {
    version: releases[0][1].version,
    sources: Object.fromEntries(
      releases.map(([system, release]) => [
        system,
        { url: release.downloadUrl },
      ])
    ),
  };
}

function getCurrentRelease() {
  return JSON.parse(readFileSync(SOURCES_FILE, "utf-8"));
}

function getHashForUrl(url) {
  const result = execFileSync(
    "nix-prefetch-url",
    ["--type", "sha256", url],
    { encoding: "utf-8" }
  ).trim();
  const sriHash = execFileSync(
    "nix",
    ["hash", "convert", "--to", "sri", "--hash-algo", "sha256", result],
    { encoding: "utf-8" }
  ).trim();
  return sriHash;
}

function releaseIsCurrent(current, latest) {
  return (
    current.version === latest.version &&
    Object.entries(latest.sources).every(
      ([system, source]) => current.sources?.[system]?.url === source.url
    )
  );
}

async function main() {
  console.log("Fetching latest Cursor release...");
  const latest = await getLatestRelease();
  console.log("Latest:", latest);

  const current = getCurrentRelease();
  console.log("Current version:", current.version);

  if (releaseIsCurrent(current, latest)) {
    console.log("Already up to date!");
    return;
  }

  console.log(`New release available: ${latest.version}`);
  for (const [system, source] of Object.entries(latest.sources)) {
    console.log(`Fetching hash for ${system}...`);
    source.hash = getHashForUrl(source.url);
  }

  console.log(`Updating ${SOURCES_FILE}...`);
  writeFileSync(SOURCES_FILE, `${JSON.stringify(latest, null, 2)}\n`);

  console.log("Done! Updated to version", latest.version);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
