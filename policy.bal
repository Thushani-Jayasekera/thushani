import ballerina/http;
import choreo/mediation;
import ballerina/log;

// A mediation policy package consists of 1-3 functions, each corresponding to one of the 3 possible request/response
// flows:
// - In-flow function is applied to a request coming in to a resource in the proxy
// - Out-flow function is applied to the response received from the upstream server before forwarding it to the client
// - Fault-flow function is applied if an error occurs in any of the above 2 flows and the control flow is handed over
//   to the error handling flow
//
// A policy can contain any combination of the above 3 flows. Therefore one can get rid of up to any 2 of the following
// functions. The function names are irrelevant. Therefore one can name them as they see fit.

// The first 2 parameters are required. After the first 2 parameters, one can add arbitrary number of parameters of
// the following types: int, string, float, boolean, decimal. However, all policy functions should have exactly the same
// number and types of these arbitrary parameters.
@mediation:RequestFlow
public function validateRequestHeader(mediation:Context ctx, http:Request req, string name, string value) returns http:Response|false|error|() {
   string|http:HeaderNotFoundError header = req.getHeader(name);
   if (header is http:HeaderNotFoundError) {
    string message = string `Header ${name} is not found`;
    log:printError(message);
    return generateResponse(message, http:STATUS_BAD_REQUEST);
   }
   if (header != value) {
    string validationFailedMessage = string `Header validation failed. Expected ${value} but found ${header}`;
    log:printError(validationFailedMessage);
    return generateResponse(validationFailedMessage, http:STATUS_BAD_REQUEST);
    }
    log:printInfo("Header validation successful");
    return ();
};

function generateResponse(string message, int statusCode) returns http:Response {
    http:Response response = new();
    response.setTextPayload(message); 
    response.statusCode = statusCode;
    return response;
}

// The first 3 parameters are required.
@mediation:ResponseFlow
public function validateResponseHeader(mediation:Context ctx, http:Request req, http:Response res, string name, string value) returns http:Response|false|error|() { 
   string|http:HeaderNotFoundError header = res.getHeader(name);
   if (header is http:HeaderNotFoundError) {
    string message = string `Header ${name} is not found`;
    log:printError(message);
    return ();
   }
   if (header != value) {
    string validationFailedMessage = string `Header validation failed. Expected ${value} but found ${header}`;
    log:printError(validationFailedMessage);
    return ();
   }
   return ();
}

// The first 5 parameters are required.
@mediation:FaultFlow
public function policyNameFault(mediation:Context ctx, http:Request req, http:Response? res, http:Response errFlowRes, 
                                    error e, string name, string value) returns http:Response|false|error|() {
    return ();
}
