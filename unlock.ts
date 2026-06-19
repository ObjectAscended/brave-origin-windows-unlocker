const os = Deno.build.os;

let localStatePathPattern: (version: string) => string;

if (os === "windows") {
  const localAppData = Deno.env.get("LOCALAPPDATA");
  if (!localAppData) {
    console.error("Error: LOCALAPPDATA environment variable not found.");
    Deno.exit(1);
  }
  localStatePathPattern = (version) =>
    `${localAppData}\\BraveSoftware\\${version}\\User Data\\Local State`;
} else if (os === "darwin") {
  const homeDir = Deno.env.get("HOME");
  if (!homeDir) {
    console.error("Error: HOME environment variable not found.");
    Deno.exit(1);
  }
  localStatePathPattern = (version) =>
    `${homeDir}/Library/Application Support/BraveSoftware/${version}/Local State`;
} else {
  console.error(`Error: Unsupported operating system: ${os}`);
  Deno.exit(1);
}

const versions = ["Brave-Origin", "Brave-Origin-Beta", "Brave-Origin-Nightly"];
let foundAny = false;

for (const version of versions) {
  const localStatePath = localStatePathPattern(version);

  try {
    const localState = JSON.parse(await Deno.readTextFile(localStatePath));

    localState.brave = localState.brave || {};
    localState.brave.origin = { purchase_validated: true };

    localState.skus = {
      state: {
        "67": JSON.stringify({
          credentials: {
            items: { "6": "7" },
          },
        }),
      },
    };

    await Deno.writeTextFile(localStatePath, JSON.stringify(localState));

    console.log(version.replace(/-/g, " ") + " unlocked successfully!");
    foundAny = true;
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) {
      continue;
    }

    throw error;
  }
}

if (!foundAny) {
  console.log("Brave Origin not found.");
}
