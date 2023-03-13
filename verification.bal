import ballerina/http;

service / on new http:Listener (9091){

    resource function get verify() returns VerifyEntry[] {
        return verifyTable.toArray();
    }
    
    resource function post verify (@http:Payload VerifyEntry[] verifyEntries) returns VerifyEntry[]|ConflictEmailsError {
        string[] conflictingEmails = from VerifyEntry verifyEntry in verifyEntries where verifyTable.hasKey(verifyEntry.email) select verifyEntry.email;

        if conflictingEmails.length() > 0 {
            return {
                body: {
                    errmsg: string:'join(" ", "Conflicting emails:", ...conflictingEmails)
                }
            };
        } else {
            verifyEntries.forEach(verifyEntry => verifyTable.add(verifyEntry));
            return verifyEntries;
        }
    }

    resource function get verify/[string email] () returns VerifyEntry|InvalidMailError {
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

public type ConflictEmailsError record {|
    *http:Conflict;
    ErrMsg body;
|};

public type ErrMsg record {|
    string errmsg;
|};

public type InvalidMailError record {|
    *http:NotFound;
    ErrMsg body;
|};
