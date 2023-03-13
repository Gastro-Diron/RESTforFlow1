import ballerina/random;

public function genCode () returns int|error {
    int randomInteger = check random:createIntInRange(1000, 9999);
    return randomInteger;
}