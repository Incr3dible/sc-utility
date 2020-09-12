namespace SupercellUilityApi.Models
{
    public class GameStatus
    {
        public string GameName { get; set; }
        public int Status { get; set; }
        public string LatestFingerprintSha { get; set; }
        public string LatestFingerprintVersion { get; set; }
        public long LastUpdated { get; set; }
    }
}