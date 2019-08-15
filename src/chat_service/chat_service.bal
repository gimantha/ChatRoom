import ballerina/http;
import ballerina/log;

final string NAME = "NAME";
map<string> joinedUsers = {};

@http:ServiceConfig {
    basePath: "/chat"
}
service chatAppUpgrader on new http:Listener(9090) {
    @http:ResourceConfig {
        webSocketUpgrade: {
            upgradePath: "/{user}",
            upgradeService: chatApp
        }
    }
    resource function upgrader(http:Caller caller, http:Request req, string user) {
        http:WebSocketCaller wsEp;

        map<string> headers = {};

        if (joinedUsers.hasKey(user)) {
            var err = caller->cancelWebSocketUpgrade(400, "User name '" + user + "' already taken");
            if (err is http:WebSocketError) {
                log:printError("Error cancelling handshake", <error>err);
            }
            return;
        }
        joinedUsers[user] = user;
        wsEp = caller->acceptWebSocketUpgrade(headers);
        wsEp.setAttribute(NAME, user);
        string msg = "Hi " + user + "! You have successfully join the chat!";
        var err = wsEp->pushText(msg);

        if (err is http:WebSocketError) {
            log:printError("Error sending message", <error>err);
        }
    }
}

map<http:WebSocketCaller> connectionsMap = {};

service chatApp = @http:WebSocketServiceConfig {} service {
    resource function onOpen(http:WebSocketCaller caller) {
        string msg;
        msg = getAttributeStr(caller, NAME) + " joined the chat";
        log:printInfo(msg);
        broadcast(msg);
        connectionsMap[caller.getConnectionId()] = caller;
    }

    resource function onText(http:WebSocketCaller caller, string text) {
        string msg = getAttributeStr(caller, NAME) + ": " + text;
        log:printInfo(msg);
        broadcast(msg);
    }

    resource function onClose(http:WebSocketCaller caller, int statusCode, string reason) {
        _ = connectionsMap.remove(caller.getConnectionId());
        string name = getAttributeStr(caller, NAME);
        string msg = name + " left the chat";
        _ = joinedUsers.remove(name);
        log:printInfo(msg);
        broadcast(msg);
    }
};

function broadcast(string text) {
    foreach var con in connectionsMap {
        var err = con->pushText(text);
        if (err is http:WebSocketError) {
            log:printError("Error sending message", <error>err);
        }
    }
}

function getAttributeStr(http:WebSocketCaller ep, string key) returns (string) {
    var name = ep.getAttribute(key);
    return name.toString();
}
