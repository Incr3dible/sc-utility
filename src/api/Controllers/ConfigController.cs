using Microsoft.AspNetCore.Mvc;
using SupercellUilityApi.Models;

namespace SupercellUilityApi.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class ConfigController : ControllerBase
    {
        [HttpGet]
        public ApiConfig Get()
        {
            var config = Resources.Configuration;

            return new ApiConfig
            {
                Maintenance = config.Maintenance,
                GlobalLiveMode = config.GlobalLiveMode
            };
        }

        [HttpPost]
        public IActionResult Post(string devToken, [FromBody] ApiConfig value)
        {
            var config = Resources.Configuration;

            if (config.DevToken != devToken)
                return Unauthorized();

            config.Maintenance = value.Maintenance;
            config.GlobalLiveMode = value.GlobalLiveMode;
            config.Save();

            return Ok();
        }
    }
}