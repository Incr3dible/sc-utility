using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace SupercellUilityApi.Models
{
    public class Fingerprint
    {
        [JsonPropertyName("files")] public List<AssetFile> Files { get; set; }
        [JsonPropertyName("sha")] public string Sha { get; set; }
        [JsonPropertyName("version")] public string Version { get; set; }


    }
}
