Builds and installs the latest versions of Nginx and the [Nginx JavaScript module (njs)](https://nginx.org/en/docs/njs/) for MacOS.

Explicitly supports njs JavaScript modules [`ngx_http_js_module`](https://nginx.org/en/docs/http/ngx_http_js_module.html) and [`ngx_stream_js_module`](https://nginx.org/en/docs/stream/ngx_stream_js_module.html).

## Usage

```sh
./build-nginx.sh        # Compile and install Nginx
build/nginx/sbin/nginx  # Start Nginx server
```
