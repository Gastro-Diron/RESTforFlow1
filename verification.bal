import ballerina/http;

service / on new http:Listener (9091){

    resource function get verify() returns VerifyEntry[] {
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

    resource function get verify/[string email] () returns string|InvalidEmailError|VerifyEntry? {
        VerifyEntry? verifyEntry = verifyTable[email];
        if verifyEntry is () {
            return {
                body: {
                    errmsg: string `Invalid Email: ${email}`
                }
            };
        } else{
            if verifyEntry.code is "1234" {
                return "The code is correct";
        }
        }
        return verifyEntry;
    }
}

public type VerifyEntry record {|
    readonly string email;
    string code;
|};

public final table <VerifyEntry> key(email) verifyTable = table [];
