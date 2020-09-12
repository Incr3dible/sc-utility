using System.Net.Http;
using System.Threading.Tasks;

namespace SupercellUilityApi.Models
{
    public class EventImageUrl
    {
        public string GameName { get; set; }
        public string ImageUrl { get; set; }

        public string GetHost()
        {
            return GameName switch
            {
                "Clash Royale" => "https://event-assets.clashroyale.com/",
                "Clash of Clans" => "https://event-assets.clashofclans.com/",
                _ => null
            };
        }

        public async Task<bool> EventExists()
        {
            var client = new HttpClient();
            var host = GetHost();

            var request = new HttpRequestMessage(
                HttpMethod.Head,
                host + ImageUrl);

            var response = await client.SendAsync(request);
            return response.IsSuccessStatusCode;
        }
    }
}