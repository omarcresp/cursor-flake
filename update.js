const response = await fetch("https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=latest", { headers: { 'User-Agent': 'Cursor-Version-Checker', 'Cache-Control': 'no-cache', } });

const json = await response.json();

console.log(json)
