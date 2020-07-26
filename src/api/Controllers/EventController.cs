using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using SupercellUilityApi.Core;
using SupercellUilityApi.Models;

namespace SupercellUilityApi.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class EventController : ControllerBase
    {
        private readonly ILogger<EventController> _logger;

        public EventController(ILogger<EventController> logger)
        {
            _logger = logger;
        }

        [HttpGet]
        public IEnumerable<EventImageUrl> Get()
        {
            return new[]
            {
                new EventImageUrl
                {
                    GameName = "Clash Royale",
                    ImageUrl = "https://event-assets.clashroyale.com/00d185b3-6a66-4590-b135-111db091acb9_party_mode_2v2.png"
                },
                new EventImageUrl
                {
                    GameName = "Clash Royale",
                    ImageUrl = "https://event-assets.clashroyale.com/00e9b381-0e5a-4212-84d6-f27dec4f98f2_fisherman_teaser_challenge.png"
                }
            };
        }

        [HttpPost]
        public async Task<IActionResult> Post([FromBody] EventImageUrl value)
        {
            Resources.IncrementRequests();

            if (!Constants.EventGames.Contains(value.GameName)) return BadRequest();

            var exists = await value.EventExists();

            if (exists)
                // TODO: SAVE TO DB
                return Ok();

            return NotFound();
        }
    }
}