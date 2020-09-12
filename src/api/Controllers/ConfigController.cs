using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;

namespace SupercellUilityApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ConfigController : ControllerBase
    {
        // GET: api/<ConfigController>
        [HttpGet]
        public IEnumerable<string> Get()
        {
            return new[] {"value1", "value2"};
        }

        // GET api/<ConfigController>/5
        [HttpGet("{id}")]
        public string Get(int id)
        {
            return "value";
        }

        // POST api/<ConfigController>
        [HttpPost]
        public void Post([FromBody] string value)
        {
        }
    }
}