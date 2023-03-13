import ballerina/io;

public function saveData (json content) returns error? {
    io:Error? result = io:fileWriteJson("/Users/gastro/Documents/Databases/Temporary/temporary.json", content);
    return result;
}

// public function saveData (map<anydata>[] content) returns error? {
//     io:Error? result = io:fileWriteCsv("/Users/gastro/Documents/Databases/Temporary/sample.csv", content, APPEND);
// }

// // type Coord record {int x;int y;};
// // Coord[] contentRecord = [{x: 1,y: 2},{x: 1,y: 2}]
// // string[][] content = [["Anne", "Johnson", "SE"], ["John", "Cameron", "QA"]];
// // io:Error? result = io:fileWriteCsv("./resources/myfile.csv", content);
// // io:Error? resultRecord = io:fileWriteCsv("./resources/myfileRecord.csv", contentRecord);