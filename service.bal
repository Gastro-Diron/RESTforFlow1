import ballerina/http;
//import ballerina/log;

public type UserEntry record {|
    readonly string email;
    string firstName;
    string lastName;
    string age;
    string country;
    string DoB;
    string bankAccountNumber;
|};

public final table <UserEntry> key(email) userTable = table [
    {email: "gastrodiron@gmail.com", firstName: "Gastro Diron", lastName: "Alexander", age: "23", DoB: "2000.01.18",country: "SriLanka", bankAccountNumber: "12345"}
];

type ConflictingemailsError record {|
    
|};

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

service /flow1 on new http:Listener (9000){
    resource function get users() returns UserEntry[] {
        return userTable.toArray();
    }
    
    resource function post users (@http:Payload UserEntry[] userEntries) returns UserEntry[]|ConflictingEmailsError {
        string[] conflictingEmails = from UserEntry userEntry in userEntries where userTable.hasKey(userEntry.email) select userEntry.email;

        if conflictingEmails.length() > 0 {
            return {
                body: {
                    errmsg: string:'join(" ", "Conflicting emails:", ...conflictingEmails)
                }
            };
        } else {
            userEntries.forEach(userEntry => userTable.add(userEntry));
            return userEntries;
        }
    }

    resource function get users/[string email] () returns UserEntry | InvalidEmailError {
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
