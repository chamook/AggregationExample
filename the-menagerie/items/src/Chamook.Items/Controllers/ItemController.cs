using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;

namespace Chamook.Items.Controllers
{
    public class Item
    {
        public string Name { get; }
        public string Id { get; }
        public string ColourId { get; }

        public Item(string name, string id, string colourId)
        {
            Name = name ?? throw new ArgumentNullException(nameof(name));
            Id = id ?? throw new ArgumentNullException(nameof(id));
            ColourId = colourId ?? throw new ArgumentNullException(nameof(colourId));
        }
    }


    public class ItemController : Controller
    {
        public static string RedId = "abc123";
        public static string YellowId = "def456";
        public static string BlueId = "ghi789";

        [HttpGet("/items/{colourId}")]
        public IActionResult Get(string colourId)
        {
            if (string.Equals(colourId, RedId, StringComparison.OrdinalIgnoreCase))
            {
                return Ok(
                    new {
                        Items = new [] {
                            new Item("Rose", "1", RedId)
                        }});
            }

            if (string.Equals(colourId, BlueId, StringComparison.OrdinalIgnoreCase))
            {
                return Ok(
                    new {
                        Items = new [] {
                            new Item("Violet", "2", RedId)
                        }});
            }

            return Ok(new { Items = new Item[0]});
        }
    }
}
