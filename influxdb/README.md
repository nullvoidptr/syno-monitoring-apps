## Building from source

By default we fetch releases from the web. If we pass an environment variable to
make (eg. INFLUXDB_BUILD_FROM_SOURCE) then it should instead build from source.

### Building influxdb ###
See details at https://github.com/influxdata/influxdb/blob/master/CONTRIBUTING.md

- clone git repo
- ensure gdm is installed
- checkout correct branch
- gdm restore
- go clean ./...
- go install ./...  (or perhaps individual go builds?)
   - may need to pass ldflags
