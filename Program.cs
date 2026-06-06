using System;
using System.IO;
using System.Text.Json;
using System.Text.Json.Nodes;

namespace BraveUnlocker
{
    class Program
    {
        static int Main()
        {
            string? localAppData = Environment.GetEnvironmentVariable("LOCALAPPDATA");
            if (string.IsNullOrEmpty(localAppData))
            {
                Console.Error.WriteLine("Error: LOCALAPPDATA environment variable is not set.");
                return 1;
            }

            string[] versions = { "Brave-Origin", "Brave-Origin-Beta", "Brave-Origin-Nightly" };
            bool foundAny = false;

            foreach (var version in versions)
            {
                string localStatePath = Path.Combine(localAppData, "BraveSoftware", version, "User Data", "Local State");

                try
                {
                    if (!File.Exists(localStatePath))
                    {
                        continue;
                    }

                    string jsonText = File.ReadAllText(localStatePath);
                    JsonNode? root = JsonNode.Parse(jsonText);

                    if (root is JsonObject rootObject)
                    {
                        // 1. localState.brave.origin = { purchase_validated: true }
                        if (!rootObject.TryGetPropertyValue("brave", out var braveNode) || braveNode is not JsonObject braveObject)
                        {
                            braveObject = new JsonObject();
                            rootObject["brave"] = braveObject;
                        }
                        braveObject["origin"] = new JsonObject
                        {
                            ["purchase_validated"] = true
                        };

                        // 2. localState.skus = { state: { "67": JSON.stringify({ credentials: { items: { "6": "7" } } }) } }
                        var credentialsObj = new JsonObject
                        {
                            ["items"] = new JsonObject
                            {
                                ["6"] = "7"
                            }
                        };
                        var sku67Obj = new JsonObject
                        {
                            ["credentials"] = credentialsObj
                        };
                        string sku67JsonString = sku67Obj.ToJsonString();

                        var stateObj = new JsonObject
                        {
                            ["67"] = sku67JsonString
                        };

                        var skusObj = new JsonObject
                        {
                            ["state"] = stateObj
                        };

                        rootObject["skus"] = skusObj;

                        var options = new JsonSerializerOptions { WriteIndented = false };
                        string updatedJson = rootObject.ToJsonString(options);

                        // using a temp file to prevent file corruption
                        string tempPath = localStatePath + ".tmp";
                        File.WriteAllText(tempPath, updatedJson);
                        if (File.Exists(localStatePath))
                        {
                            File.Delete(localStatePath);
                        }
                        File.Move(tempPath, localStatePath);

                        string displayName = version.Replace("-", " ");
                        Console.WriteLine($"{displayName} unlocked successfully!");
                        foundAny = true;
                    }
                    else
                    {
                        Console.Error.WriteLine($"Error: Local State in {version} is not a valid JSON object.");
                    }
                }
                catch (FileNotFoundException)
                {
                    continue;
                }
                catch (DirectoryNotFoundException)
                {
                    continue;
                }
                catch (Exception ex)
                {
                    Console.Error.WriteLine($"Error updating {version}: {ex.Message}");
                    return 1;
                }
            }

            if (!foundAny)
            {
                Console.WriteLine("Brave Origin not found.");
            }

            return 0;
        }
    }
}
