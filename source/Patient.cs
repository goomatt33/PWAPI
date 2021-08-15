using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace PWAPI.source
{
    public class Patient
    {
        public string LName { get; set; }
        public string FName { get; set; }
        public string MiddleI { get; set; }
        public string Birthdate { get; set; }
        public string SSN { get; set; }
        public string Address { get; set; }
        public string Address2 { get; set; }
        public string City { get; set; }
        public string State { get; set; }
        public string Zip { get; set; }
        public string HmPhone { get; set; }
        public string WirelessPhone { get; set; }


        public void PatientFromSql(string sqlString)
        {
            LName = sqlString.Substring(0, 128);
            sqlString = sqlString.Remove(0, 129);
            LName = LName.Trim();

            FName = sqlString.Substring(0, 128);
            sqlString = sqlString.Remove(0, 129);
            FName = FName.Trim();

            MiddleI = sqlString.Substring(0, 1);
            sqlString = sqlString.Remove(0, 2);
            MiddleI = MiddleI.Trim();

            int offset = sqlString.IndexOf(" ");
            offset = sqlString.IndexOf(" ", offset + 1);
            offset = sqlString.IndexOf(" ", offset + 1);
            Birthdate = sqlString.Substring(0, offset);
            sqlString = sqlString.Remove(0, offset + 1);

            SSN = sqlString.Substring(0, 9);
            sqlString = sqlString.Remove(0, 10);
            SSN = SSN.Trim();

            Address = sqlString.Substring(0, 128);
            sqlString = sqlString.Remove(0, 129);
            Address = Address.Trim();

            Address2 = sqlString.Substring(0, 128);
            sqlString = sqlString.Remove(0, 129);
            Address2 = Address2.Trim();

            City = sqlString.Substring(0, 128);
            sqlString = sqlString.Remove(0, 129);
            City = City.Trim();

            State = sqlString.Substring(0, 128);
            sqlString = sqlString.Remove(0, 129);
            State = State.Trim();

            Zip = sqlString.Substring(0, 5);
            sqlString = sqlString.Remove(0, 6);
            Zip = Zip.Trim();

            HmPhone = sqlString.Substring(0, 32);
            sqlString = sqlString.Remove(0, 33);
            HmPhone = HmPhone.Trim();

            WirelessPhone = sqlString.Substring(0, 32);
            sqlString = sqlString.Remove(0, 33);
            WirelessPhone = WirelessPhone.Trim();
        }
    }
}