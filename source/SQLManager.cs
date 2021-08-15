/* The SQL Manager class
 * This class manages the Sql server context and the connection
 * to that server.
 * Written by Matthew Burke for ABSC Inc.
 * Last Updated: 7-13-21
 */

using System;
using System.Data.SqlClient;
using System.Text;

namespace PWAPI
{
	class SqlManager
	{
		private String server { get; set; }     // Server name
		private String userID { get; set; }     // SQL User name
		private String password { get; set; }       // SQL user password
		private String database { get; set; }       // Sql Database to use
		private SqlConnection serverConnection; // The sql connection handle
		private bool connected;                 // True while connected, otherwise false
		private String exception { get; set; }  // Sql exception string
		public String Exception { get { return exception; } }       // Public accesspr fpr 

		/* Create an empty sql manager
		 * NOT RECOMMENDED
		 */
		public SqlManager()
		{
			server = "";
			userID = "";
			password = "";
			database = "";
			connected = false;
		}
		/* Create a new sql manager
		 * PARAMS:
		 * String server - the server to connect to
		 * String UserID - username for the connection
		 * String Password - the users password
		 * String Database - database on the server to use
		 */
		public SqlManager(String Server, String UserID, String Password, String Database)
		{
			server = Server;
			userID = UserID;
			password = Password;
			database = Database;
			connected = false;
		}
		/* Create a connection string for connecting
		 * to the server
		 * RETURNS:
		 * String - the connection string
		 */
		public String buildConnectionString()
		{
			SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder();

			builder.DataSource = server;
			builder.UserID = userID;
			builder.Password = password;
			builder.InitialCatalog = database;
			return builder.ConnectionString;
		}
		/* Connects to the server using the
		 * parameters created with the constructor
		 * RETURNS:
		 * bool - true if successfully connected, otherwise false
		 * REMARKS:
		 * If connectToServer returns false, SqlManager.Exception can
		 * be used to access the exception that caused the failure
		 */
		public bool connectToServer()
		{
			try
			{
				serverConnection = new SqlConnection(buildConnectionString());

				serverConnection.Open();
				connected = true;

			}
			catch (SqlException e)
			{
				connected = false;
				exception = e.ToString();
			}
			return connected;
		}
		/* Closes the connection to the sql server
		 */
		public void disconnectFromServer()
		{
			serverConnection.Close();
		}
		/* Makes a query to the SQL server based
		 * on the query string. Queries must be fully
		 * formed SQL statements. A class that extends
		 * SqlManager and contains a statment parser
		 * is recommended for this purpose.
		 * PARAMS:
		 * String query - the sql query to execute
		 * RETURNS:
		 * String - the result of the query
		 * REMARKS:
		 * The return string will only contain the
		 * results of SQL statments that you would
		 * expect to return a result. For instance, 
		 * INSERT statments will return an emtpy string.
		 * It is recommeneded to impliment checks on the
		 * database in the same expection class as the
		 * parser.
		 */
		public String makeQuery(String query)
		{
			String re = "";
			try
			{
				using (SqlCommand command = new SqlCommand(query, serverConnection))
				{
					using (SqlDataReader reader = command.ExecuteReader())
					{
						while (reader.Read())
						{
							for (int i = 0; i < reader.FieldCount; i++)
							{
								re += reader.GetValue(i);
								re += " ";
							}
							re += "\n";
						}
					}
				}
				return re;
			}
			catch (SqlException e)
			{
				exception = e.ToString();
				return re;
			}
		}
	}
}