# PCInterface
nginx接口开发
接口涉及到md5防盗链验证，有两种方案：
1、通过access_by_lua_file手动验证防盗链的有效时间、md5值等，需要验证nginx的ngx.md5()加密方式对应java的加密方法；
2、使用nginx的secure_link_module的加密验证方式，需要需要将请求方式转为get；
第一种方法比较灵活简便，但是此处使用第二张方式。
流程：请求进来，首先通过子请求转为get，第二步进行md5验证，最后进行业务处理。好了，废话不多说，直接上代码。

