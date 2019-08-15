import ballerina/http;
import ballerina/io;
import ballerina/log;

public function main(string... args) {
    string REMOTE_BACKEND = "ws://localhost:9090/chat/";
    if (args.length() == 1 && args[0].trim().length() > 0) {
		REMOTE_BACKEND = args[0];
	}
    string name = io:readln("Enter a username to join the chat: ");

    while (name.trim().length() < 1) {
        name = io:readln("Username cannot be empty. Enter a valid username to join the chat: ");
    }

    http:WebSocketClient wsClientEp = new (
    REMOTE_BACKEND + name,
    {
        callbackService: ClientService,
        readyOnConnect: false
    });

    var err = wsClientEp->ready();
    if (err is http:WebSocketError) {
        log:printError("Error calling ready on client", <error>err);
        log:printInfo("Please retry later...");
        return;
    } else {
        while (true) {
            string msg = io:readln("");
            if (!(msg.trim().length() < 1)) {
                var result = wsClientEp->pushText(msg);
                if (result is http:WebSocketError) {
                    log:printError("Error sending message", <error>result);
                }
            }
        }
    }
}

service ClientService = @http:WebSocketServiceConfig {} service {
    resource function onText(http:WebSocketClient caller, string text) {
        io:println(text);
    }
};
