# PlayArray

## Installs Required

XCode 8.0

Swift 3

Carthage

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a framework manager for our project.
Current frameworks:
* [Alamofire](https://github.com/Alamofire/Alamofire) - Used for API Communication

Install Carthage using Homebrew
```
brew update
brew install carthage
carthage update --platform ios
```

`carthage update` must be run in the same directory as the Cartfile

## API Communication

Server URL: `http://cloud-vm-46-57.doc.ic.ac.uk:3000/api/v1/`

Communicating with the API is done through the RequestManager framework. The RequestManager is accessed in PlayArray by calling the `Request` object, e.g. `Request.getPlaylist(...)`.

Our communication is RESTful. Currently implemented API calls are as follows:


| Function | Description | HTTP Method | Path |
| --- | --- |:---:| --- |
| getPlaylist(from time:) | Obtains a playlist from the server based on passed time of day | GET | /playlist?local_time= |
| getPlaylist(from weather:) | Obtains a playlist from the server based on passed weather | GET | /playlist?weather= |
| getWeather | Returns current weather conditions at passed longitude and latitude | GET | http://api.openweathermap.org/data/2.5/weather? |

Here, `getPlaylist` only contains separate functions in this sprint. Eventually we should be able to pass a JSON string as a single parameter, which will contain information about different criteria, and will be parsed by the server.

### Data Format

**This does not apply to checkpoint 1**

Data is sent in JSON format

#### getPlaylist

```json
[
    {
        "local_time" : String,
        "weather" : [String]
    }
]
```
