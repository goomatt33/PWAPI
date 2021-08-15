<!--#include virtual="code/util_sql.aspx"-->
<!--#include virtual="code/code_email.aspx"-->
<!--#include virtual="code/code_user_settings.aspx"-->

<script runat="server">

    Sub Page_Load()

        If Not IsNothing(Request.Cookies("PatientWeb.user.pr.id")) Then If Request.Cookies("PatientWeb.user.pr.id").Value <> "" Then Response.Redirect("main.aspx")

    End Sub

    Sub resetAlert()

        div_alert.Visible = False
        div_alert_txt.Attributes.Clear()
        div_alert_txt.Attributes.Add("class", "alert alert-warning")

    End Sub

    Sub login()

        resetAlert()

        resetArray(0)
        setArrayParam("username", Request.Form("username"), 1, 0)

        Using sc As SqlConnection = New SqlConnection(conn)
            sc.Open()

            Dim rsLogin As SqlDataReader = executeSQL(sc, "select password_isTemp, passwordSalt, passwordHash, user_id, pr_id, role_pw, isActive, isSuperUser, user_type from Users WHERE username = @username", variableArray, valueArray)

            If rsLogin.Read Then

                If rsLogin("role_pw") = 0 Or Not rsLogin("isActive") Then
                    div_alert.Visible = True
                    div_alert_txt.InnerHtml = "Account Inactive. Please contact your administrator for further assistance."
                    'ElseIf rsLogin("user_type") = 2 Then
                    'div_alert.Visible = True
                    'div_alert_txt.InnerHtml = "Lab Access no Longer Available."
                ElseIf StrComp(CreateHash(Request.Form("pword"), rsLogin("passwordSalt").ToString), rsLogin("passwordHash").ToString) <> 0 Then
                    div_alert.Visible = True
                    div_alert_txt.InnerHtml = "Invalid Password"
                Else

                    Response.Cookies("PatientWeb.user.pr.id").Value = rsLogin("user_id").ToString + ":" + rsLogin("pr_id").ToString
                    Response.Cookies("PatientWeb.user.pr.id").Expires = DateAdd(DateInterval.Hour, 12, Now)
                    Response.Cookies("PatientWeb.user.pr.id").Secure = True

                    Response.Redirect(getRedirect(rsLogin("password_isTemp")))

                End If

            Else
                div_alert.Visible = True
                div_alert_txt.InnerHtml = "Username Not Found. Please contact your administrator for further assistance."
            End If

            rsLogin.Close()
            rsLogin = Nothing

        End Using

    End Sub

    Function getRedirect(password_isTemp As Boolean) As String

        Dim isToken As Boolean = False
        If Not IsNothing(Request.QueryString("token")) Then If Request.QueryString("token").ToString <> "" Then isToken = True

        Dim isPage As Boolean = False
        If Not IsNothing(Request.QueryString("pg")) Then If Request.QueryString("pg").ToString <> "" Then isPage = True

        Dim redir As String
        If isToken Then
            Return Request.QueryString("pg") + "?type=" + Request.QueryString("type") + "&token=" + Request.QueryString("token")
        Else
            If password_isTemp Then
                Return "profile.aspx"
            Else
                If isPage Then
                    Return Request.QueryString("pg") + "?" + Request.QueryString("qs")
                Else
                    Return "main.aspx"
                End If
            End If
        End If

    End Function

    Sub remind()

        resetAlert()

        resetArray(0)
        setArrayParam("email", Request.Form("email"), 1, 0)

        Dim numFound As Integer = getNumFound("select count(user_id) as cnt from Users where isVerified = 1 AND email = @email")

        If numFound <= 1 Then

            Using sc_remind As SqlConnection = New SqlConnection(conn)
                sc_remind.Open()

                Dim rsRemind As SqlDataReader = executeSQL(sc_remind, "select username, user_id from Users where isVerified = 1 AND email = @email", variableArray, valueArray)

                If rsRemind.Read Then

                    Dim temp As String = updateTempPassword("Users", "user_id", rsRemind("user_id"))

                    sendReminderEmail(rsRemind("username"), temp, Request.Form("email"))

                Else
                    div_alert.Visible = True
                    div_alert_txt.InnerHtml = "Email Address Not Found. Please contact your administrator for further assistance."
                End If

                rsRemind.Close()
                rsRemind = Nothing

            End Using

        Else
            div_alert.Visible = True
            div_alert_txt.InnerHtml = "Multiple provider accounts have been found for that email. Please contact <a href='mailto:customersupport@patientweb.com'>customersupport@patientweb.com</a>."
        End If

    End Sub

    Function getNumFound(sql As String) As Integer

        Dim c As Integer

        Using sc_remind As SqlConnection = New SqlConnection(conn)
            sc_remind.Open()

            Dim rsCnt As SqlDataReader = executeSQL(sc_remind, sql, variableArray, valueArray)

            If rsCnt.Read Then c = rsCnt("cnt")

            rsCnt.Close()
            rsCnt = Nothing

        End Using

        Return c

    End Function

    Function updateTempPassword(tbl As String, idName As String, idValue As Integer) As String

        Dim salt As String = CreateSalt(5)
        Dim temp As String = CreateSalt(5)
        Dim hash As String = CreateHash(temp, salt)

        resetArray(2, 2)
        setArrayParam("id", idValue, 2, 0)
        setArrayParam("passwordHash", hash, 2, 1)
        setArrayParam("passwordSalt", salt, 2, 2)

        Using sc_temp As SqlConnection = New SqlConnection(conn)
            sc_temp.Open()
            ExecuteNonQuery(sc_temp, "update " + tbl + " set password_isTemp = 1, passwordSalt = @passwordSalt, passwordHash = @passwordHash where " + idName + " = @id", variableArray2, valueArray2)
        End Using

        Return temp

    End Function

    Sub sendReminderEmail(username As String, temppword As String, email As String)

        Dim strBody As New StringBuilder

        strBody.Append(emailHeader("Credentials"))
        strBody.Append("<p>Your credentials for PatientWeb are provided below. For security purposes, you will be prompted to change your password when you log in for the first time.</p>")
        strBody.Append("<p><b>Username</b>: " + username + "</p>")
        strBody.Append("<p><b>Temporary Password</b>: " + temppword + "</p>")
        strBody.Append("<p><a href='" + pwURL + "'><img src='" + pwURL + "app-assets/images/btn-log-in.png' height='30' /></a></p>")
        strBody.Append(emailFooter())

        sendEmail(strBody.ToString, email, "", "Customer Support", "PatientWeb Credentials")

        div_alert.Visible = True
        div_alert_txt.Attributes.Add("class", "alert alert-success")
        div_alert_txt.InnerHtml = "An email has been sent to you with instructions on how to reset your password."

    End Sub

    Sub loginPatient()

        resetAlert()

        resetArray(0)
        setArrayParam("username", Request.Form("pt_username"), 1, 0)

        Using sc As SqlConnection = New SqlConnection(conn)
            sc.Open()

            Dim rsLogin As SqlDataReader = executeSQL(sc, "select password_isTemp, passwordSalt, passwordHash, p_id from Patients WHERE username = @username", variableArray, valueArray)

            If rsLogin.Read Then

                If StrComp(CreateHash(Request.Form("pt_password"), rsLogin("passwordSalt").ToString), rsLogin("passwordHash").ToString) <> 0 Then
                    div_alert.Visible = True
                    div_alert_txt.InnerHtml = "Invalid Password"
                Else

                    Response.Cookies("PatientWeb.Patient.id").Value = rsLogin("p_id").ToString
                    Response.Cookies("PatientWeb.Patient.id").Expires = DateAdd(DateInterval.Hour, 12, Now)
                    Response.Cookies("PatientWeb.Patient.id").Secure = True

                    Response.Redirect(getRedirect(rsLogin("password_isTemp")))

                End If

            Else
                div_alert.Visible = True
                div_alert_txt.InnerHtml = "Username Not Found. Please contact your administrator for further assistance."
            End If

            rsLogin.Close()
            rsLogin = Nothing

        End Using

    End Sub

    Sub remindPatient()

        resetAlert()

        resetArray(0)
        setArrayParam("email", Request.Form("pt_email"), 1, 0)

        Dim numFound As Integer = getNumFound("SELECT COUNT(DISTINCT p.p_id) AS cnt FROM Patients AS p INNER JOIN Practices_Specific_Patient_Data AS s ON p.p_id = s.p_id GROUP BY s.email HAVING s.email = @email")

        If numFound <= 1 Then

            Using sc_remind As SqlConnection = New SqlConnection(conn)
                sc_remind.Open()

                Dim rsRemind As SqlDataReader = executeSQL(sc_remind, "SELECT distinct username, p.p_id FROM Patients AS p INNER JOIN Practices_Specific_Patient_Data AS s ON p.p_id = s.p_id where s.email = @email", variableArray, valueArray)

                If rsRemind.Read Then

                    Dim temp As String = updateTempPassword("Patients", "p_id", rsRemind("p_id"))

                    sendReminderEmail(rsRemind("username"), temp, Request.Form("pt_email"))

                Else
                    div_alert.Visible = True
                    div_alert_txt.InnerHtml = "Email Address Not Found. Please contact your administrator for further assistance."
                End If

                rsRemind.Close()
                rsRemind = Nothing

            End Using

        Else
            div_alert.Visible = True
            div_alert_txt.InnerHtml = "Multiple patient accounts have been found for that email address. Please contact <a href='mailto:customersupport@patientweb.com?subject=Patient-Access-for-" + Request.Form("pt_email") + "'>customersupport@patientweb.com</a> for assistance."
        End If

    End Sub

</script>

<!--#include virtual="incl/layout_head.inc" --></head>

<body class="vertical-layout vertical-menu-modern 1-column bg-login-main menu-expanded blank-page blank-page" data-open="click" data-menu="vertical-menu-modern" data-col="1-column">
<div class="app-content content">
    <div class="content-wrapper">
        <div class="content-header row"></div>
        <div class="content-body">
            
            <section class="flexbox-container">
                
                <div class="col-12 d-flex align-items-center justify-content-center">
                    <div class="col-lg-5 col-md-7 col-sm-8 col-xs-11 box-shadow-2 p-0">
                        <div class="card border-grey border-lighten-3 px-1 py-1 m-0">
                            <div class="card-header border-0">
                                <div class="card-title text-center"><img src="app-assets/images/logo/logo.png" alt="PatientWeb" style="max-width:350px"></div>
                            </div>
                            <div class="card-content">
                                
                                <!--div class="text-center"><h3 class="warning"><strong>** PATIENTWEB HAS BEEN REVAMPED **</strong></h3></!--div-->
                                    
                                <form class="form-horizontal" runat="server" defaultbutton="">
                                <asp:ScriptManager ID="ScriptManager" EnablePartialRendering="true" runat="server"></asp:ScriptManager>
   
                                    
                                <asp:UpdatePanel id="up_always" UpdateMode="Always" runat="server">
                                <ContentTemplate>
                                    <div class="form-group" id="div_alert" visible="false" runat="server">
                                        <div class="col-12 mt-2">
                                            <div ID="div_alert_txt" runat="server"></div>
                                        </div>
                                    </div>
                                </ContentTemplate>
                                </asp:UpdatePanel>

                                <asp:UpdatePanel id="up_login" UpdateMode="Conditional" ChildrenAsTriggers="False" runat="server">
                                <ContentTemplate>

                                <!-- REMINDER -->
                                <asp:Panel cssclass="card-body" id="pnl_remind" style="display:none" DefaultButton="btn_remind" runat="server">
                                    <p>Enter the email address that we have on file and we will send you an email to reset your password.</p>
                                    
                                    <fieldset class="form-group position-relative">
                                        <div class="input-group">
								            <asp:Textbox id="email" cssclass="form-control" placeholder="Email Address" data-validation-regex-regex="([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})" runat="server" />
                                            <div class="input-group-append">
									            <asp:Button id="btn_remind" cssclass="btn btn-info" OnClick="remind" ValidationGroup="vg_remind" Text="GO" runat="server" />
								            </div>    
							            </div>
                                        <asp:RequiredFieldValidator id="fv_email" ControlToValidate="email" Display="Dynamic" Text="* Email Address is Required" CssClass="red" ValidationGroup="vg_remind" runat="server" />
                                        <asp:RegularExpressionValidator id="rev_email" ControlToValidate="email" Display="Dynamic" Text="* Invalid Email Address" CssClass="red" ValidationGroup="vg_remind" ValidationExpression="([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})" runat="server" />
                                    </fieldset>
                                    <div class="form-group row smaller">
                                        <div class="col-12 text-center"><a class="text-uppercase" onclick="showLogin()">Cancel, Back to Log In</a></div>
                                    </div>
                                </asp:Panel>
                                    
                                <!-- LOG IN -->
                                <asp:Panel cssclass="card-body" id="pnl_login" DefaultButton="btn_login" runat="server">

                                    <fieldset class="form-group position-relative has-icon-left">
                                        <asp:Textbox cssclass="form-control" id="username" placeholder="Username" runat="server" />
                                        <div class="form-control-position">
                                            <i class="ft-user"></i>
                                        </div><asp:RequiredFieldValidator id="fv_username" ControlToValidate="username" Display="Dynamic" Text="* Username is Required" CssClass="red" ValidationGroup="vg_login" runat="server" />
								    </fieldset>
                                    <fieldset class="form-group position-relative has-icon-left">
                                        <asp:Textbox type="password" cssclass="form-control" id="pword" placeholder="Password" runat="server" />
                                        <div class="form-control-position">
                                            <i class="la la-key"></i>
                                        </div><asp:RequiredFieldValidator id="fv_pword" ControlToValidate="pword" Display="Dynamic" Text="* Password is Required" CssClass="red" ValidationGroup="vg_login" runat="server" />
                                    </fieldset>
                                    
									<asp:Button ID="btn_login" cssclass="btn btn-success btn-block text-uppercase" OnClick="login" Text="Provider Log In" ValidationGroup="vg_login" runat="server" /> 
                                    <asp:Hyperlink ID="btn_signup" cssclass="btn btn-sm btn-info btn-block mt-2 text-uppercase" NavigateUrl="account.aspx" Text="I am a New Provider to PatientWeb" runat="server" /> 
                                
                                    <div class="form-group row mt-2 mb-0 text-uppercase">
                                        <div class="col-md-6 col-sm-12 text-center">
                                            <span class="bold pwblue font16" style="border-bottom:solid 1px #000;padding-bottom:8px">Are you a Patient ?</span>
                                            <p class="mt-1"><a class="smaller" onclick="showPatientLogin()">Click Here to Access Patient Log In</a></p>
                                        </div>
                                        <div class="col-md-6 col-sm-12 text-center smaller mt-1">
                                            <a onclick="showRemind()">Forgot Username or Password</a>
                                        </div>
                                    </div>
                                   
                                </asp:Panel>

                                <!-- PATIENT REMINDER -->
                                <asp:Panel cssclass="card-body" id="pnl_patient_remind" style="display:none" DefaultButton="btn_remind_patient" runat="server">
                                    <p>Enter the email address that we have on file and we will send you an email to reset your password.</p>
                                    
                                    <fieldset class="form-group position-relative">
                                        <div class="input-group">
								            <asp:Textbox id="pt_email" cssclass="form-control" placeholder="Email Address" data-validation-regex-regex="([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})" runat="server" />
                                            <div class="input-group-append">
									            <asp:Button id="btn_remind_patient" cssclass="btn btn-info" OnClick="remindPatient" ValidationGroup="vg_remind_patient" Text="GO" runat="server" />
								            </div>    
							            </div>
                                        <asp:RequiredFieldValidator id="fv_pt_email" ControlToValidate="pt_email" Display="Dynamic" Text="* Email Address is Required" CssClass="red" ValidationGroup="vg_remind_patient" runat="server" />
                                        <asp:RegularExpressionValidator id="rev_pt_email" ControlToValidate="pt_email" Display="Dynamic" Text="* Invalid Email Address" CssClass="red" ValidationGroup="vg_remind_patient" ValidationExpression="([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})" runat="server" />
                                    </fieldset>
                                    <div class="form-group row smaller">
                                        <div class="col-12 text-center"><a class="text-uppercase" onclick="showPatientLogin()">Cancel, Back to Log In</a></div>
                                    </div>
                                </asp:Panel>
                                    
                                <!-- PATIENT LOG IN -->
                                <asp:Panel cssclass="card-body" id="pnl_patient_login" style="display:none" DefaultButton="btn_patient_login" runat="server">

                                    <asp:Literal ID="ltl_pt_text" runat="server" />
                                    
                                    <fieldset class="form-group position-relative has-icon-left">
                                        <asp:Textbox cssclass="form-control" id="pt_username" placeholder="Username" runat="server" />
                                        <div class="form-control-position">
                                            <i class="ft-user"></i>
                                        </div><asp:RequiredFieldValidator id="fv_pt_username" ControlToValidate="pt_username" Display="Dynamic" Text="* Username is Required" CssClass="red" ValidationGroup="vg_login_patient" runat="server" />
									</fieldset>
                                    <fieldset class="form-group position-relative has-icon-left">
                                        <asp:Textbox type="password" cssclass="form-control" id="pt_password" placeholder="Password" runat="server" />
                                        <div class="form-control-position">
                                            <i class="la la-key"></i>
                                        </div><asp:RequiredFieldValidator id="fv_pt_password" ControlToValidate="pt_password" Display="Dynamic" Text="* Password is Required" CssClass="red" ValidationGroup="vg_login_patient" runat="server" />
                                    </fieldset>
                                    
									<asp:Button ID="btn_patient_login" cssclass="btn btn-success btn-block text-uppercase" OnClick="loginPatient" ValidationGroup="vg_login_patient" Text="Patient Log In" runat="server" /> 
                                    
                                    <div class="form-group row mt-2 mb-0 text-uppercase">
                                        <div class="col-md-6 col-sm-12 text-center">
                                            <span class="bold pwblue font16" style="border-bottom:solid 1px #000;padding-bottom:8px">Are you a Provider ?</span>
                                            <p class="mt-1"><a class="smaller" onclick="showLogin()">Click Here to Access Provider Log In</a></p>
                                        </div>
                                        <div class="col-md-6 col-sm-12 text-center smaller mt-1">
                                            <a onclick="showPatientRemind()">Forgot Username or Password</a>
                                        </div>
                                    </div>
                                   
                                </asp:Panel>
                               
                                </ContentTemplate>
                                </asp:UpdatePanel>

                                <center><hr /><h4>SECURELY CONNECTING DOCTORS TOGETHER</h4></center>
                    
                                </form>

                            </div>
                        </div>
                    </div>


                </div>
            </section>

            
        </div>
    </div>
</div>
    
    
<!--#include virtual="incl/js_base.inc"-->

<script type="text/javascript">

    
    function showRemind() { $("#pnl_remind").show(); $("#pnl_login").hide(); $("#pnl_patient_remind").hide(); $("#pnl_patient_login").hide(); };
    function showLogin() { $("#pnl_remind").hide(); $("#pnl_login").show(); $("#pnl_patient_remind").hide(); $("#pnl_patient_login").hide(); };
    
    
    function showPatientRemind() { $("#pnl_remind").hide(); $("#pnl_login").hide(); $("#pnl_patient_remind").show(); $("#pnl_patient_login").hide(); };
    function showPatientLogin() { $("#pnl_remind").hide(); $("#pnl_login").hide(); $("#pnl_patient_remind").hide(); $("#pnl_patient_login").show(); };

</script>

</body>
</html>