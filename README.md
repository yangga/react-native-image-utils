# React Native Image Utils

## Installation 🚀🚀

```
$ npm install react-native-image-utils --save

or

$ yarn add react-native-image-utils
```

then,
```
$ react-native link react-native-image-utils
```



#### Android Only

If you do not already have openCV installed in your project, add this line to your `settings.gradle`

```
include ':openCVLibrary310'
project(':openCVLibrary310').projectDir = new File(rootProject.projectDir,'../node_modules/react-native-image-utils/android/ZdependencyZopenCVLibrary310')
```

Add below into MainApplication.java
```java
public class MainApplication extends Application implements ReactApplication {
    ////// insert this
    static{
        System.loadLibrary("opencv_java3");
    }
    /////////////////////
```


in MainApplication.java
public class MainApplication ... {
```
static{
    System.loadLibrary("opencv_java3");
  }
```


## Usage

#### Rotating(90 degrees only) images
```javascript
import { transOrientRotate } from 'react-native-image-utils'

...

const outputOption = null;
const uri = 'https://i.ytimg.com/vi/YCaGYUIfdy4/maxresdefault.jpg';
const param = {
    degrees: 90
}

transOrientRotate(null, uri, param)).then((response) => {                        
                        // 'response.uri' is new path of created image
                      }).catch((err) => {
                        console.error(err)
                      });

```

#### `Multiful Executions (for saving performace)`
Multiful calling functions is heavy because it creates image files in each calls. Here is the way efficientious. (It runs in order.)

```javascript
import { proxies } from 'react-native-image-utils'

...

const uri = 'https://i.ytimg.com/vi/YCaGYUIfdy4/maxresdefault.jpg';

const commands = []

// color scaling
commands.push({
    cmd: 'scaleCSB',
    param: {
        contrast: 50,
        saturation: 10,
        brightness: -30,
    }
})

// then, cropping
commands.push({
    cmd: 'cropPerspective',
    param: {
        topLeft: ...,
        topRight: ...,
        bottomLeft: ...,
        bottomRight: ...,
        width: ...,
        height: ...,
    }
})

// then, do something more...
commands.push({
    cmd: ...,
    param: {
        ...
    }
})

...

// You can also choose some options for output file
const OutputOption = {
    format: 'JPEG',
    quality: 0.9,
    ...
}

// Let's execute commands
// One execute to multiful commands. It creates image file just 1 time.
proxies(OutputOption, uri, commands)
.then(res => {
    // 'response.uri' is new URI of created image
})
.catch(err => {
    console.error(err)
})

```

## Interfaces
Name | Description
------ | -----------
cropPerspective | cropping by perspective
cropRoundedCorner | cropping rounded image
scaleCSB | scaling color by Contrast, Saturation and Brightness. (In developping. It makes different result on ios and android.)
transOrientRotate | rotating image by 90 degrees (90, 180, 270 only)
proxy | single command calling
proxies | multiful command calling

> and, you can check any interfaces and parameters in `index.d.ts` file.

## Output Options
Name | Description
------ | -----------
format | Image file format
quality | Image quality
path | Specified path of new image file

## Contribution
Welcome to anyone.
