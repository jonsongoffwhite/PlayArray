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

Communicating with the API is done through the RequestManager framework. The RequestManager is accessed in PlayArray by calling the `Request` object, e.g. `Request.getPlaylist(...)`.

Our communication is RESTful. Currently implemented API calls are as follows:


| Function | Description | HTTP Method | Path |
| --- | --- |:---:| --- |
| getPlaylist | Obtains a playlist from the server based on passed criteria | GET | /playlist (placeholder?) |

### Data Format

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
