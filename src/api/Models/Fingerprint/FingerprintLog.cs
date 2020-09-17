namespace SupercellUilityApi.Models
{
    public class FingerprintLog
    {
        public string Sha { get; set; }
        public string Version { get; set; }
        public long Timestamp { get; set; }
        public bool HasJson { get; set; }
    }
}