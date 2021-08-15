using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace PWAPI.source
{
    public class JSON
    {
        private string jsonString { get; }

        JSON ()
        {
            jsonString = "";
        }

        JSON (string JsonString)
        {
            jsonString = JsonString;
        }




    }
}