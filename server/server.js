var http = require('http');
var url = require('url');

// not fully rfc compliant but ok for testing
function uuidv4() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

var accessToken = uuidv4();

var users = [
    {
        "name": "Viki Dobreva",
        "id": 1,
        "events" : [1, 3],
        "profile-pic": "https://www.sonypark360.net/wp-content/uploads/2017/08/profile-pictures.png"
    },
    {
        "name": "Petar",
        "id": 2,
        "events" : [2],
        "profile-pic": "https://www.sonypark360.net/wp-content/uploads/2017/08/profile-pictures.png"
    }
]

var events = [
    {
        "name": "Beerfest",
        "id": 1,
        "location" : "Sofia"
    },
    {
        "name": "Some event",
        "id": 2,
        "location" : "Burgas"
    },
    {
        "name": "Ski competition",
        "id": 3,
        "location" : "Bansko"
    }
]

console.log("Generated access token: " + accessToken)

commonHeaders = {
    "Content-type": "application/json"
};

function setResponse(res, code, headers, data) {
    res.statusCode = code;
    for (var k in headers) {
        res.setHeader(k, headers[k])
    }
    if (! (data instanceof String)) {
        data = JSON.stringify(data)
    }
    data += '\r\n'
    res.setHeader("Content-Length", Buffer.byteLength(data))
    res.end(data)
}

function onLogin(req, res) {
    var query = url.parse(req.url, true).query;

    if(query.user == "admin" && query.pass == "pass") {
        setResponse(res, 200, commonHeaders, {"access-token" : accessToken})
    } else {
        setResponse(res, 403, {}, "Error in authrorization")
    }
}

function onUser(req, res) {
    if(req.headers["access-token"] == accessToken) {
        setResponse(res, 200, commonHeaders, users[0])
    } else {
        setResponse(res, 403, {}, "Error")
    }
}

function onOtherUser(req, res) {
    if(req.headers["access-token"] == accessToken) {
        var query = url.parse(req.url, true).query;
        if (query.userid <= users.length) {
            setResponse(res, 200, commonHeaders, users[query.userid - 1])
        } else {
            setResponse(res, 400, {}, "No such user")
        }
    } else {
        setResponse(res, 403, {}, "Error")
    }
}

function onTrending(req, res) {
    if(req.headers["access-token"] == accessToken) {
        setResponse(res, 200, commonHeaders, {"ids": [1, 3]})
    } else {
        setResponse(res, 403, {}, "Error")
    }
}

function onEvent(req, res) {
    if(req.headers["access-token"] == accessToken) {
        var query = url.parse(req.url, true).query;

        if (query.eventid <= events.length) {
            setResponse(res, 200, commonHeaders, events[query.eventid - 1])
        } else {
            setResponse(res, 400, {}, "No such event")
        }
    } else {
        setResponse(res, 403, {}, "Error")
    }
}

function onAddEvent(req, res) {
    if(req.headers["access-token"] == accessToken) {
        var query = url.parse(req.url, true).query;

        var event = {}
        event.id = events.length
        event.name = query.name
        event.location = query.location

        events.push(event)
        setResponse(res, 200, commonHeaders, {"id": event.id + 1})

    } else {
        setResponse(res, 403, {}, "Access denied")
    }
}

http.createServer(function (req, res) {
    var request = url.parse(req.url, true);

    var path = request.pathname;

    if(req.method == "GET") {
        switch(path) {
            // login
            case "/login":
                onLogin(req, res)
                break;

            case "/userinfo":
                onUser(req, res)
                break;

            case "/user":
                onOtherUser(req, res)
                break;

            case "/trending":
                onTrending(req, res)
                break;

            case "/event":
                onEvent(req, res)
                break;

            // used to test sent data return the sent data
            case "/test":
                setResponse(res, 200, {}, request)

            // no such option
            default:
                setResponse(res, 404, {}, "API not available")
        }
    }

    if(req.method == "POST") {
        switch(path) {

            case "/addevent":
                onAddEvent(req, res)
                break;

            // no such option
            default:
                setResponse(res, 404, {}, "API not available")
        }
    }

    console.log(req.method + " " + path + " " + res.statusCode + " " + res.statusMessage)

}).listen(8080);
