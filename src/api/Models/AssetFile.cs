using System.Text.Json.Serialization;

namespace SupercellUilityApi.Models
{
    public class AssetFile
    {
        [JsonPropertyName("sha")] public string Sha { get; set; }
        [JsonPropertyName("file")] public string File { get; set; }
    }
}
