import ballerina/http;

service / on new http:Listener (9091){

    resource function get verify() returns VerifyEntry[] {
        //error? mailer  = email:sendEmail("gastrodiron@gmail.com");
        return verifyTable.toArray();
    }
    
    resource function post verify (@http:Payload VerifyEntry[] userEntries) returns VerifyEntry[]|ConflictingEmailsError {
        string[] conflictingEmails = from VerifyEntry verifyEntry in userEntries where userTable.hasKey(verifyEntry.email) select verifyEntry.email;
        string toemail = from VerifyEntry verifyEntry in userEntries select verifyEntry.email;

        if conflictingEmails.length() > 0 {
            return {
                body: {
                    errmsg: string:'join(" ", "Conflicting emails:", ...conflictingEmails)
                }
            };
        } else {
            userEntries.forEach(verifyEntry => verifyTable.add(verifyEntry));
            return userEntries;
        }
    }

    resource function get verify/[string email] () returns VerifyEntry|InvalidEmailError {
        VerifyEntry? verifyEntry = verifyTable[email];
        if verifyEntry is () {
            return {
                body: {
                    errmsg: string `Invalid Email: ${email}`
                }
            };
        }
        return verifyEntry;
    }
}

public type VerifyEntry record {|
    readonly string email;
    string code;
|};

public final table <VerifyEntry> key(email) verifyTable = table [];

//public type UserEntry record {|
//     readonly string email;
//     string name;
//     string country;
// |};

// public final table <UserEntry> key(email) userTable = table [
//     {email: "summa@gmail.com", name: "Gastro Diron", country: "SriLanka"}
// ];

// public type ConflictingEmailsError record {|
//     *http:Conflict;
//     ErrorMsg body;
// |};

// public type ErrorMsg record {|
//     string errmsg;
// |};

// public type InvalidEmailError record {|
//     *http:NotFound;
//     ErrorMsg body;
// |};
