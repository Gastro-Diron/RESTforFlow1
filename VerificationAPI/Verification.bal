import ballerina/http;
//import VerificationAPI.fileAccess;

service / on new http:Listener (9091){

    resource function get verify() returns string[][]|error?|VerifyEntry[] {
        return verifyTable.toArray();
    }
    
    resource function post verify (@http:Payload VerifyEntry[] verifyEntries) returns VerifyEntry[]|ConflictingEmailsError {
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

    resource function get verify/[string email] () returns string|InvalidEmailError|VerifyEntry?|error {
        //json userClaims = check fileAccess:readData(email);
        VerifyEntry? verifyEntry = verifyTable[email];
        if verifyEntry is () {
            return {
                body: {
                    errmsg: string `Invalid Email: ${email}`
                }
            };
        } else{
            if verifyEntry.code is "1234" {
                //error? addToStore = check fileAccess:saveData(userClaims,email+"perm");
                return "The code is correct";
            } else {
                return "Invalid Code";
            }
        }
        //return verifyEntry;
    }
}

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

public type VerifyEntry record {|
    readonly string email;
    string code;
|};

public final table <VerifyEntry> key(email) verifyTable = table [];
