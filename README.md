HttpCapture
====
因为现在市面上关于Http抓包的应用HttpWatch Basic，只能访问Alexa Top 20的网站，要分析其他网站需要付1024元购买正式版，所以做了个小工具，基本实现HttpWatch的功能，抓取本app内的的http、https请求，以及header、content、cookies、query strings、post values，查看console.log、ping、域名解析、trace等。工程使用Xcode7.3.1环境和swift2.3、oc，还未使用swift3.0，后面有时间会及时更新。