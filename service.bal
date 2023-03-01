import ballerina/http;
import ballerina/log;

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
|}

service /flow1 on new http:Listener (9090){
    resource function post UserDetails (@http:Payload UserEntry[] userEntries) returns UserEntry[]|ConflictingEmailsError {
        string[] conflictingEmails = from UserEntry userEntry in userEntries where userTable.hasKey(userEntry.email) select userEntry.email;

        if Conflictingemails.length() > 0 {
            return {
                body: {
                    errmsg: string: 'join(" ", "Conflicting emails:", ...conflictingEmails)
                }
            };
        } else {
            userEntries.forEach(userEntry => userTable.add(userEntry));
            return userEntries;
        }
    }
}

listener http:Listener serviceListner = new (9090);

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for generating greetings
    # + name - the input string name
    # + return - string name with hello message or error
    resource function get greeting(string name) returns string|error {
        // Send a response back to the caller.
        if name is "" {
            return error("name should not be empty!");
        }
        return "Hello, " + name;
    }
}
