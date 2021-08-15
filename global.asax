<%@ Application Language="CS" %>

<script runat="server">

        Using System;
    Using System.Collections.Generic;
    Using System.Linq;
    Using System.Web;
    Using System.Web.Optimization;
    Using System.Web.Routing;
    Using System.Web.Http;
    Using System.Web.Security;
    Using System.Web.SessionState;

    Namespace PWAPI
    {
        Public Class Global :   HttpApplication
        {
            void Application_Start(Object sender, EventArgs e)
            {
                // Code that runs on application startup
                RouteConfig.RegisterRoutes(RouteTable.Routes);
                BundleConfig.RegisterBundles(BundleTable.Bundles);

                RouteTable.Routes.MapHttpRoute(
                    name: "DefalutAPI",
                    routeTemplate: "api/{controller}/{id}",
                    defaults: New { id = System.Web.Http.RouteParameter.Optional }
                    );
            }

            void Session_Start(Object sender, EventArgs e)
            {
                If (Request.IsSecureConnection)
                {
                    Response.Cookies["ASP.NET_SessionID"].Secure = true;
                }
            }
        }
    }

</script>