import {
    NativeModules,
} from 'react-native';

function proxies(outOption, imgSrcUri, proxyParams) {
    const outOptionAdjusted = {
        format: 'PNG',
        quality: 1.0,
        path: '',

        ...outOption
    }

    return new Promise((resolve, reject) => {
        NativeModules.RNImageUtils.proxies(
            outOptionAdjusted,
            imgSrcUri, 
            proxyParams, 
            (err, response) => err ? reject(err) : resolve(response)
        )
    })
}

function proxy(outOption, imgSrcUri, cmd, param) {
    return proxies(outOption, imgSrcUri, [{cmd, param}])
}

function generateIF_1(cmd) {
    return (outOption, imgSrcUri, param) => proxy(outOption, imgSrcUri, cmd, param);
}

export {
    proxy,
    proxies,
    generateIF_1,
}
