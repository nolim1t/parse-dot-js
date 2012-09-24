request = require 'request'

parselib = {
	geoqueryClassCollection: (info, callback) ->
		if info.classname != undefined and info.lat != undefined and info.long != undefined and info.radius != undefined
			url = "https://api.parse.com/1/classes/" + info.classname + "?where="
			geoquerybuilder = {
				"geo": {
					"$nearSphere": {
						"__type": "GeoPoint",
						"latitude": info.lat,
						"longitude": info.long 
					},
					"$maxDistanceInKilometers": info.radius
				}
			}
			url = url + encodeURIComponent(JSON.stringify(geoquerybuilder))
			if process.env.PARSEAPPID != undefined and process.env.PARSERESTKEY != undefined
				request {uri: url, timeout: 5, method: 'GET', headers: {"X-Parse-Application-Id": process.env.PARSEAPPID, "X-Parse-REST-API-Key": process.env.PARSERESTKEY}}, (error, response, body) ->
					if not error
						if JSON.parse(body).error == undefined
							callback({success: 'OK', result: JSON.parse(body)})
						else
							callback({success: 'NO', message: 'An error has occured: ' + JSON.parse(body).error})
					else
						callback({success: 'NO', message: 'An error has occured: ' + error})
			else
				callback({success: 'NO', message: 'Parse API Key not set'})
		else
			callback({success: 'NO', message: 'Missing parameters'})

	checkClass: (info, callback) ->
		if info.classname != undefined
			url = "https://api.parse.com/1/classes/" + info.classname
			if info.objectid != undefined
				url = url + "/" + info.objectid
			if process.env.PARSEAPPID != undefined and process.env.PARSERESTKEY != undefined
				request {uri: url, timeout: 5, method: 'GET', headers: {"X-Parse-Application-Id": process.env.PARSEAPPID, "X-Parse-REST-API-Key": process.env.PARSERESTKEY}}, (error, response, body) ->
					if not error
						callback({success: 'OK', result: JSON.parse(body)})
					else
						callback({success: 'NO', message: 'An error has occured: ' + error})
			else
				callback({success: 'NO', message: 'Parse API Key not set'})
		else
			callback({success: 'NO', message: 'Missing parameters'})

	checkUser: (info, callback) ->
		if info.username != undefined
			url = "https://api.parse.com/1/users/" + info.username
			if process.env.PARSEAPPID != undefined and process.env.PARSERESTKEY != undefined
				request {uri: url, timeout: 5, method: 'GET', headers: {"X-Parse-Application-Id": process.env.PARSEAPPID, "X-Parse-REST-API-Key": process.env.PARSERESTKEY, "X-Parse-Session-Token": info.session}}, (error, response, body) ->
					if not error
						if JSON.parse(body).sessionToken != undefined
							validSession = true
						else
							validSession = false

						callback({success: 'OK', result: JSON.parse(body), sessionIsValid: validSession})
					else
						callback({success: 'NO', message: 'An error has occurred: ' + error})
			else
				callback({success: 'NO', message: 'Parse API Key not set'})
		else
			callback({success: 'NO', message: 'Missing parameters'})

	# Sending iOS push (can change to android if needed)
	push: (info, callback) ->
		if info.channels != undefined and info.message != undefined
			url = 'https://api.parse.com/1/push'
			postbody = {
				channels: info.channels,
				type: 'ios',
				data: {
					alert: info.message
				}
			}
			if process.env.PARSEAPPID != undefined and process.env.PARSERESTKEY != undefined
				request {uri: url, timeout: 5, method: 'POST', body: JSON.stringify(postbody), headers: {"X-Parse-Application-Id": process.env.PARSEAPPID, "X-Parse-REST-API-Key": process.env.PARSERESTKEY, "Content-Type": "application/json"}}, (error, response, body) ->
					if not error
						if JSON.parse(body).error == undefined
							callback({success: 'OK', status: true, result: JSON.parse(body)})
						else
							callback({success: 'NO', status: false, message: JSON.parse(body).error, errorcode: JSON.parse(body).code})
					else
						callback({success: 'NO', status: false, message: 'An error has occurred: ' + error})


}
module.exports = parselib
