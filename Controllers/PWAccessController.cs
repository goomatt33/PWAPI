using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

using Newtonsoft.Json;

namespace PWAPI.Controllers
{
    public class PWAccessController : ApiController
    {
        // GET: api/PWAccess
        //public IEnumerable<string> Get()
        //{
        //    return new string[] { "value1", "value2" };
        //}

        [HttpGet]
        [AllowAnonymous]
        public string Token([FromBody]string value)
        {
            //Query query = new Query("GET", value);

            source.Patient patient = JsonConvert.DeserializeObject<source.Patient>(value);
            Query query = new Query("GET", patient);

            SqlManager sqlManager = new SqlManager("pwdev-server.database.windows.net",
                "sadmin",
                "0fMice&Men",
                "PWDev");
            if (!sqlManager.connectToServer())
            {
                return "An error has occured connecting to the sql server: " + sqlManager.Exception;
            }
            string val = sqlManager.makeQuery(query.sqlQuery);
            if(val.Length <= 0)
            {
                return "No patient with specified data exists!";
            }
            sqlManager.disconnectFromServer();

            source.Patient retPatient = new source.Patient();
            retPatient.PatientFromSql(val);

            string jsonString = JsonConvert.SerializeObject(retPatient);

            return jsonString;
        }

        //public string Get([FromBody]string value)
        //{

        //    Query query = new Query("GET", value);
        //    return query.sqlQuery;
        //}

        // GET: api/PWAccess/5
        public string Get(int id)
        {
            return "value";
        }

        // POST: api/PWAccess
        public string Post([FromBody]string value)
        {
            source.Patient patient = JsonConvert.DeserializeObject<source.Patient>(value);

            Query query = new Query("POST", patient);
            
             SqlManager sqlManager = new SqlManager("pwdev-server.database.windows.net",
                "sadmin",
                "0fMice&Men",
                "PWDev");
            if (!sqlManager.connectToServer())
            {
                return "An error has occured connecting to the sql server: " + sqlManager.Exception;
            }
            string val = sqlManager.makeQuery(query.sqlQuery);
            sqlManager.disconnectFromServer();

            return val;
        }

        // PUT: api/PWAccess/5
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE: api/PWAccess/5
        public void Delete(int id)
        {
        }
    }
}
