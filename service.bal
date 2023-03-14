import ballerina/http;
import flow1.email;
import flow1.filewrite;
//import flow1.codegen;

service /flow1 on new http:Listener (9090){

    resource function get users() returns UserEntry[] {
        return userTable.toArray();
    }
    
    resource function post users (@http:Payload UserEntry[] userEntries) returns UserEntry[]|ConflictingEmailsError {
        string[] conflictingEmails = from UserEntry userEntry in userEntries where userTable.hasKey(userEntry.email) select userEntry.email;
        string toemail = from UserEntry userEntry in userEntries select userEntry.email;

        if conflictingEmails.length() > 0 {
            return {
                body: {
                    errmsg: string:'join(" ", "Conflicting emails:", ...conflictingEmails)
                }
            };
        } else {
            userEntries.forEach(userEntry => userTable.add(userEntry));
            //string|error? code = codegen:genCode();
            error? data = filewrite:saveData(userEntries);
            error? mailer  = email:sendEmail(toemail);
            return userEntries;
        }
    }

    resource function get users/[string email] () returns UserEntry|InvalidEmailError {
        UserEntry? userEntry = userTable[email];
        if userEntry is () {
            return {
                body: {
                    errmsg: string `Invalid Email: ${email}`
                }
            };
        }
        return userEntry;
    }
}

public type UserEntry record {|
    readonly string email;
    string name;
    string country;
|};

public final table <UserEntry> key(email) userTable = table [
    {email: "summa@gmail.com", name: "Gastro Diron", country: "SriLanka"}
];

public type ConflictingEmailsError record {|
    *http:Conflict;
    ErrorMsg body;
|};

public type ErrorMsg record {|
    string errmsg;
|};

public type InvalidEmailError record {|
    *http:NotFound;
    ErrorMsg body;
|};
