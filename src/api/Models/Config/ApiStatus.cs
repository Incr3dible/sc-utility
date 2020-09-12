namespace SupercellUilityApi.Models
{
    public class ApiStatus
    {
        public long TotalApiRequests { get; set; }
        public long UptimeSeconds { get; set; }
        public bool Maintenance { get; set; }
    }
}