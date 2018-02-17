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
    },
    {
        "name": "Kalin",
        "id": 3,
        "events" : [3],
        "profile-pic": "https://www.sonypark360.net/wp-content/uploads/2017/08/profile-pictures.png"
    },
    {
        "name": "Asen",
        "id": 4,
        "events" : [3],
        "profile-pic": "https://www.sonypark360.net/wp-content/uploads/2017/08/profile-pictures.png"
    }
]

var events = [
    {
        "name": "Beerfest",
        "id": 1,
        "location" : "Sofia",
        "created-by" : 1,
        "participants": [1],
        "images": [
            "http://images.mentalfloss.com/sites/default/files/styles/mf_image_3x2/public/beerfest.png?itok=y9cLMuKD&resize=1100x740",
            "https://beerfests.com/laravel-frontend/public/uploads/blogs/thumb/survive-beerfest.jpg"
        ]
    },
    {
        "name": "Some event",
        "id": 2,
        "location" : "Burgas",
        "created-by" : 2,
        "participants": [2],
        "images": [
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTjIULiQ5LSnq_hzWnovENr2PnCaRzVpZYVTc4hW08m0UwucIOkMw"
        ]
    },
    {
        "name": "Ski competition",
        "id": 3,
        "location" : "Bansko",
        "created-by" : 1,
        "participants": [1, 3, 4],
        "images": [
            "http://agentpalmer.com/wp-content/uploads/2014/02/Olympic-Skiing-Events.jpg",
            "http://i.telegraph.co.uk/multimedia/archive/02657/SkicrossBODY2_2657502a.jpg",
            "https://usatthebiglead.files.wordpress.com/2016/11/gettyimages-512843548.jpg?w=1000&h=600&crop=1"
        ]
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
        event['created-by'] = 1

        events.push(event)
        setResponse(res, 200, commonHeaders, {"id": event.id + 1})

        users[0].events.push(event.id + 1)

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
