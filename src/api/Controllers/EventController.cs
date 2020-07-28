using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using SupercellUilityApi.Core;
using SupercellUilityApi.Database;
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
        public IEnumerable<EventImage> Get(string gameName)
        {
            var events = Resources.EventCache.GetCachedEvents(gameName);
            return events;
        }

        [HttpPost]
        public async Task<IActionResult> Post([FromBody] EventImageUrl value)
        {
            Resources.IncrementRequests();

            if (!Constants.EventGames.Contains(value.GameName)) return BadRequest();
            if (Resources.EventCache.ContainsUrl(value.GameName, value.GetHost() + value.ImageUrl)) return Ok();

            var exists = await value.EventExists();
            if (!exists) return NotFound();

            await EventDatabase.SaveEvent(value);
            return Ok();
        }
    }
}