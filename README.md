Builds and installs the latest version of [Nginx](https://nginx.org/en/) for macOS (Darwin / Apple).

Includes the [Nginx JavaScript module (njs)](https://nginx.org/en/docs/njs/), which enables [`ngx_http_js_module`](https://nginx.org/en/docs/http/ngx_http_js_module.html) and [`ngx_stream_js_module`](https://nginx.org/en/docs/stream/ngx_stream_js_module.html).

## Usage

```sh
./install.sh            # Compile and install Nginx
build/nginx/sbin/nginx  # Start Nginx server
```
