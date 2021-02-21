# morpheus-scotty-haxl-sample
* based on https://github.com/morpheusgraphql/morpheus-graphql 's morpheus-graphql-examples-scotty. Thanks a lot for great product.
* using app(>=0.16.0), not available in hackage.
* using simgle root path in scotty.
* using submodule.

## clone
```
git clone --recursive https://github.com/ynishi/morpheus-scotty-haxl-sample.git
```

## with stack
* Just build and execute with stack(or install, as you like).
* install and execute sample is below.
```
stack install
morpheus-scotty-haxl-sample-exe
# using port 3000
```

## graphql ui
* available graphql ui in
```
http://localhost:3000
```
* do query sample
```
query {
  deity(deityId:10) {
    name
  }
}
```
* will return below.
```
{
  "data": {
    "deity": {
      "name": "10"
    }
  }
}
```
