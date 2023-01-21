# knetwork2json

Get information about balance from internet provider https://knetwork.ru/

1. Create file `input.json` with login and password that you use with https://knetwork.ru/

```
$ cat input.json
{
    "login": "12345",
    "password": "************"
}
```

2. Run the docker image and pass directories to it. Inside docker the file on the host `input.json` shoud be available as `/input/input.json` and the directory in the docker `/output/` should be avalible somewhere on the host, for example:

```
$ docker run -v `pwd`/input.json:/input/input.json -v `pwd`/output/:/output/ bessarabov/knetwork2json:1.0.0
```

3. After the docker is run in the ouput directory on the host you can see the data about your account balane. It is situated in file `output.json` (inside docker it is at `/output/output.json`, on the host it is where you have specified it in the docker command).

```
$ cat output/output.json
{
    "is_success" : true,
    "balance" : 483.46
}
```
