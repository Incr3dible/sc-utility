namespace SupercellUilityApi.Models
{
    public class EventImage
    {
        public string GameName { get; set; }
        public string ImageUrl { get; set; }
        public string File { get; set; }
        public long Timestamp { get; set; }

        public void SetUrl(string file)
        {
            var host = GameName switch
            {
                "Clash Royale" => "https://event-assets.clashroyale.com/",
                "Clash of Clans" => "https://event-assets.clashofclans.com/",
                _ => null
            };

            ImageUrl = host + file;
            File = file;
        }
    }
}
