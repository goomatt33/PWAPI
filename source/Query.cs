using System;
using System.Data.SqlClient;
using System.Text;

namespace PWAPI
{
    class Query
    {
        private string requestType;
        private string rawData;
        public string sqlQuery;

        public Query(string RequestType, source.Patient patient)
        {
            requestType = RequestType;
            sqlQuery = "";

            if (requestType == "GET")
            {
                sqlQuery += "SELECT * FROM patientData WHERE " +
                    "LName = '" + patient.LName + "' AND " +
                    "FName = '" + patient.FName + "' AND " +
                    "MiddleI = '" + patient.MiddleI + "' AND " +
                    "Birthdate = '" + patient.Birthdate + "' AND " +
                    "SSN = '" + patient.SSN + "' AND " +
                    "Address = '" + patient.Address + "' AND " +
                    "Address2 = '" + patient.Address2 + "' AND " +
                    "City = '" + patient.City + "' AND " +
                    "State = '" + patient.State + "' AND " +
                    "Zip = '" + patient.Zip + "' AND " +
                    "HmPhone = '" + patient.HmPhone + "' AND " +
                    "WirelessPhone = '" + patient.WirelessPhone + "';";
            }
            if (requestType == "POST")
            {
                sqlQuery += "INSERT INTO patientData VALUES('" +
                    patient.LName + "','" +
                    patient.FName + "','" +
                    patient.MiddleI + "','" +
                    patient.Birthdate + "','" +
                    patient.SSN + "','" +
                    patient.Address + "','" +
                    patient.Address2 + "','" +
                    patient.City + "','" +
                    patient.State + "','" +
                    patient.Zip + "','" +
                    patient.HmPhone + "','" +
                    patient.WirelessPhone + "');";
            }
        }
    }
}
