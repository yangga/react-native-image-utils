import {
    NativeModules,
} from 'react-native';

function metaReadData(imgSrcUri) {
    return new Promise((resolve, reject) => {
        NativeModules.RNImageUtils.metaReadData(
            imgSrcUri,
            (err, response) => err ? reject(err) : resolve(response)
        )
    })
}

function metaWriteData(imgSrcUri, metaData) {
    return new Promise((resolve, reject) => {
        NativeModules.RNImageUtils.metaWriteData(
            imgSrcUri,
            metaData,
            (err, response) => err ? reject(err) : resolve(response)
        )
    })
}

export {
    metaReadData,
    metaWriteData,
}
