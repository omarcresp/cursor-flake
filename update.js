import { execSync } from "child_process";
import { readFileSync, writeFileSync } from "fs";

const DOWNLOAD_API = "https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=latest";
const NIX_FILE = "default.nix";

async function getLatestVersion() {
  const response = await fetch(DOWNLOAD_API, {
    headers: {
      "User-Agent": "Cursor-Version-Checker",
      "Cache-Control": "no-cache",
    },
  });
  return response.json();
}

function getCurrentVersion() {
  const content = readFileSync(NIX_FILE, "utf-8");
  const versionMatch = content.match(/version\s*=\s*"([^"]+)"/);
  return versionMatch ? versionMatch[1] : null;
}

function getHashForUrl(url) {
  const result = execSync(`nix-prefetch-url --type sha256 "${url}"`, {
    encoding: "utf-8",
  }).trim();
  const sriHash = execSync(
    `nix hash convert --to sri --hash-algo sha256 ${result}`,
    { encoding: "utf-8" }
  ).trim();
  return sriHash;
}

function updateNixFile(version, downloadUrl, hash) {
  let content = readFileSync(NIX_FILE, "utf-8");

  content = content.replace(
    /version\s*=\s*"[^"]+"/,
    `version = "${version}"`
  );
  content = content.replace(
    /downloadUrl\s*=\s*"[^"]+"/,
    `downloadUrl = "${downloadUrl}"`
  );
  content = content.replace(
    /hash\s*=\s*"[^"]+"/,
    `hash = "${hash}"`
  );

  writeFileSync(NIX_FILE, content);
}

async function main() {
  console.log("Fetching latest Cursor version...");
  const latest = await getLatestVersion();
  console.log("Latest:", latest);

  const currentVersion = getCurrentVersion();
  console.log("Current version:", currentVersion);

  const latestVersion = latest.version;
  const downloadUrl = latest.downloadUrl;

  if (currentVersion === latestVersion) {
    console.log("Already up to date!");
    process.exit(0);
  }

  console.log(`New version available: ${latestVersion}`);
  console.log("Fetching hash for new version...");

  const hash = getHashForUrl(downloadUrl);
  console.log("Hash:", hash);

  console.log("Updating default.nix...");
  updateNixFile(latestVersion, downloadUrl, hash);

  console.log("Done! Updated to version", latestVersion);
  console.log("::set-output name=updated::true");
  console.log(`::set-output name=version::${latestVersion}`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
