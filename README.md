# knetwork2json

1. Create file `input.json` with login & password that you use with https://knetwork.ru/

    $ cat input.json
    {
        "login": "123",
        "password": "************"
    }

2. Run the docker image and pass directories to it, so that inside docker the file on the host `input.json` is available as `/input/input.json` and the directory in the docker `/output/` is avalible somewhere on the host, for example:

    $ docker run -v `pwd`/input.json:/input/input.json -v `pwd`/output/:/output/ knetwork2json:dev

3. Get the data about your account balane in the file `output.json` (inside docker it is at `/output/output.json`, on the host it is where you have specified in the docker command).

    $ cat output/output.json
    {
        "is_success" : true,
        "balance" : 483.46
    }
