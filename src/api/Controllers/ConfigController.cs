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
            return new ApiConfig
            {
                Maintenance = Resources.Configuration.Maintenance
            };
        }

        [HttpPost]
        public IActionResult Post(string devToken, [FromBody] ApiConfig value)
        {
            var config = Resources.Configuration;

            if (config.DevToken != devToken)
                return Unauthorized();

            config.Maintenance = value.Maintenance;
            config.Save();

            return Ok();
        }
    }
}